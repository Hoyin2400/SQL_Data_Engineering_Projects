select length('SQL');

select lower('SQL');

select upper('Sql');

select left('SQL', 2);

select right('SQL', 2);

select substring('SQL', 2, 2);

select concat('SQL', '-', 'Functions');

select 'SQL' || '-' || 'Functions';

select trim(' SQL ');

select replace('SQL', 'Q', '_');

select regexp_replace('data.nerd@gmail.com', '^.*(@)', '\1');


with title_lower as (
    select
        job_title,
        lower(trim(job_title)) as job_title_clean
    from job_postings_fact
)
select
    job_title,
    case
        when job_title_clean like '%data%' 
            and job_title_clean like '%analyst%' then 'Data Analyst'
        when job_title_clean like '%data%' 
            and job_title_clean like '%engineer%' then 'Data Engineer'
        when job_title_clean like '%data%' 
            and job_title_clean like '%scientist%' then 'Data Scientist'
        else 'Other'
    end as job_title_category,
    job_title_short
from job_postings_fact
order by random()
limit 20;

select nullif(5+5, 20);

select
    median(nullif(salary_year_avg, 0)),
    median(nullif(salary_hour_avg, 0))
from
    job_postings_fact
where salary_hour_avg is not null or salary_year_avg is not null
limit 10;

select coalesce(null, 1, 2);

select coalesce(null, null, 2);

select  
    salary_year_avg,
    salary_hour_avg,
    coalesce(salary_year_avg, salary_hour_avg * 2800)
from job_postings_fact
where salary_hour_avg is not null or salary_year_avg is not null
limit 10;

select
    job_title_short,
    salary_year_avg,
    salary_hour_avg,
    coalesce(salary_year_avg, salary_hour_avg * 2800) as standardized_salary,
    case
        when coalesce(salary_year_avg, salary_hour_avg * 2800) is null then 'Missing'
        when coalesce(salary_year_avg, salary_hour_avg * 2800) < 75_000 then 'Low'
        when coalesce(salary_year_avg, salary_hour_avg * 2800) < 150_000 then 'Medium'
        else 'High'
    end as salary_bucket
from job_postings_fact
order by standardized_salary desc;