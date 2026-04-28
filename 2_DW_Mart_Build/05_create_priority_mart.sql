-- Step 5: Mart - Create priority roles mart

drop schema if exists priority_mart cascade;

create schema priority_mart;

select '=== Loading Roles for Priority Mart ===' as info;
create table priority_mart.priority_roles (
    role_id         integer     primary key,
    role_name       varchar,
    priority_lvl    integer
);

insert into priority_mart.priority_roles (role_id, role_name, priority_lvl)
values
    (1, 'Data Engineer',        2),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer',    3);

select * from priority_mart.priority_roles;

select '=== Loading Snapshot for Priority Mart ===' as info;
create or replace table priority_mart.priority_jobs_snapshot (
    job_id              integer primary key,
    job_title_short     varchar,
    company_name        varchar,
    job_posted_date     timestamp,
    salary_year_avg     double,
    priority_lvl        integer,
    updated_at          timestamp
);

insert into priority_mart.priority_jobs_snapshot (
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
)
select
    jpf.job_id,
    jpf.job_title_short,
    cd.name as company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    current_timestamp
from
    job_postings_fact as jpf
left join company_dim as cd
    on jpf.company_id = cd.company_id
inner join priority_mart.priority_roles as r
    on jpf.job_title_short = r.role_name;

select
    job_title_short,
    count(*) as job_count,
    min(priority_lvl) as priority_lvl,
    min(updated_at) as updated_at
from priority_mart.priority_jobs_snapshot
group by job_title_short
order by job_count desc;