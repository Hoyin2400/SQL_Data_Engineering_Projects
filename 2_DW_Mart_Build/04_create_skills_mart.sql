-- Step 4: Mart - Create skills demand mart

drop schema if exists skills_mart cascade;

create schema skills_mart;

select '=== Loading dim_skills Table ===' as info;
create or replace table skills_mart.dim_skills (
    skill_id    integer     primary key,
    skills      varchar,
    type        varchar
);

insert into skills_mart.dim_skills (
    skill_id,
    skills,
    type
)
select
    skill_id,
    skills,
    type
from skills_dim;

select '=== Loading dim_date_month Table ===' as info;
create or replace table skills_mart.dim_date_month (
    month_start_date    date    primary key,
    year                integer,
    month               integer,
    quarter             integer,
    quarter_name        varchar,
    year_quarter        varchar
);

insert into skills_mart.dim_date_month (
    month_start_date,
    year,            
    month,           
    quarter,         
    quarter_name,    
    year_quarter    
)
select distinct
    date_trunc('month', job_posted_date) as month_start_date,
    extract(year from job_posted_date) as year,
    extract(month from job_posted_date) as month,
    extract(quarter from job_posted_date) as quarter,
    'Q-' || extract(quarter from job_posted_date)::varchar as quarter_name,
    extract(year from job_posted_date)::varchar || '-Q' || 
    extract(quarter from job_posted_date)::varchar as year_quarter
from job_postings_fact
order by month_start_date;

select '=== Loading fact_skill_demand_monthly Table ===' as info;
create or replace table skills_mart.fact_skill_demand_monthly (
    skill_id                            integer,
    month_start_date                    date,
    job_title_short                     varchar,
    postings_count                      integer,
    remote_postings_count               integer,
    health_insurance_postings_count     integer,
    no_degree_mention_postings_count    integer,
    primary key (skill_id, month_start_date, job_title_short),
    foreign key (skill_id) references skills_mart.dim_skills(skill_id),
    foreign key (month_start_date) references skills_mart.dim_date_month(month_start_date)
);

insert into skills_mart.fact_skill_demand_monthly (
    skill_id,                        
    month_start_date,                
    job_title_short,                 
    postings_count,                  
    remote_postings_count,           
    health_insurance_postings_count, 
    no_degree_mention_postings_count
)
with job_postings_prep as (
    select
        sjd.skill_id,
        date_trunc('month', jpf.job_posted_date) as month_start_date,
        jpf.job_title_short,
        -- convert boolean flags (1 or 0)
        case when jpf.job_work_from_home = true then 1 else 0 end as is_remote,
        case when jpf.job_health_insurance = true then 1 else 0 end as has_health_insurance,
        case when jpf.job_no_degree_mention = true then 1 else 0 end as no_degree_mentioned
    from 
        job_postings_fact as jpf
    inner join
        skills_job_dim as sjd
        on sjd.job_id = jpf.job_id
)
select
    skill_id,
    month_start_date,
    job_title_short,
    count(*) as postings_count,
    sum(is_remote) as remote_postings_count,
    sum(has_health_insurance) as health_insurance_postings_count,
    sum(no_degree_mentioned) as no_degree_mention_postings_count
from
    job_postings_prep
group by all
order by skill_id, month_start_date, job_title_short;



select 'Skills Dimension', count(*) from skills_mart.dim_skills
union all
select 'Date Month Dimension' as table_name, count(*) as record_count from skills_mart.dim_date_month
union all
select 'Skill Demand Fact', count(*) from skills_mart.fact_skill_demand_monthly;

select '=== Skills Dimension Sample ===' as info;
select * from skills_mart.dim_skills limit 5;

select '=== Date Month Dimension Sample ===' as info;
select * from skills_mart.dim_date_month limit 5;

select '=== Skill Demand Sample ===' as info;
select * from skills_mart.fact_skill_demand_monthly limit 5;