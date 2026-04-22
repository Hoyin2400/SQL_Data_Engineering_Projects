-- Step 2: DW - Load data from CSV files into tables

select '=== Loading company_dim Table ===' as info;

insert into company_dim (company_id, name)
select company_id, name
from read_csv('https://storage.googleapis.com/sql_de/company_dim.csv',
    auto_detect=true);

select '=== Loading skills_dim Table ===' as info;

insert into skills_dim (skill_id, skills, type)
select skill_id, skills, type
from read_csv('https://storage.googleapis.com/sql_de/skills_dim.csv',
    auto_detect=true);

select '=== Loading job_postings_fact Table ===' as info;

insert into job_postings_fact (
    job_id, company_id, job_title_short, job_title, job_location, 
    job_via, job_schedule_type, job_work_from_home, search_location,
    job_posted_date, job_no_degree_mention, job_health_insurance,
    job_country, salary_rate, salary_year_avg, salary_hour_avg      
)
select
    job_id, company_id, job_title_short, job_title, job_location, 
    job_via, job_schedule_type, job_work_from_home, search_location,
    job_posted_date, job_no_degree_mention, job_health_insurance,
    job_country, salary_rate, salary_year_avg, salary_hour_avg
from read_csv('https://storage.googleapis.com/sql_de/job_postings_fact.csv',
    auto_detect=true);

select '=== Loading skills_job_dim Table ===' as info;

insert into skills_job_dim (skill_id, job_id)
select skill_id, job_id
from read_csv('https://storage.googleapis.com/sql_de/skills_job_dim.csv',
    auto_detect=true);

select 'Company Dim' as table_name, count(*) as record_count from company_dim
union all
select 'Skills Dim', count(*) from skills_dim
union all
select 'Job Postings Fact', count(*) from job_postings_fact
union all
select 'Skills Job Dim', count(*) from skills_job_dim;

select '=== Company Dimension Sample ===' as info;
select * from company_dim limit 5;

select '=== Skills Dimension Sample ===' as info;
select * from skills_dim limit 5;

select '=== Job Postings Fact Sample ===' as info;
select * from job_postings_fact limit 5;

select '=== Skills Job Bridge Sample ===' as info;
select * from skills_job_dim limit 5;