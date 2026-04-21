-- Count Rows - Aggregation Only
select
    count(*)
from
    job_postings_fact;

-- Count Rows - Window Function
select
    job_id,
    count(*) over ()
from
    job_postings_fact;

-- PARTITION BY - Find hourly salary
select
    job_id,
    job_title_short,
    company_id,
    salary_hour_avg,
    avg(salary_hour_avg) over (
        partition by job_title_short, company_id
    )
from
    job_postings_fact
where 
    salary_hour_avg is not null
order by 
    random()
limit 10;


-- ORDER BY - Ranking hourly salary
select
    job_id,
    job_title_short,
    company_id,
    salary_hour_avg,
    rank() over (
        order by salary_hour_avg desc
    ) as rank
from
    job_postings_fact
where 
    salary_hour_avg is not null
order by 
    salary_hour_avg desc
limit 10;

-- PARTITION BY & ORDER BY - Running Average Hourly Salary
select
    job_posted_date,
    job_title_short,
    salary_hour_avg,
    avg(salary_hour_avg) over (
        partition by job_title_short
        order by job_posted_date
    ) as running_avg_hourly_by_title
from
    job_postings_fact
where
    salary_hour_avg is not null
order by
    job_title_short,
    job_posted_date
limit 10;

-- PARTITION BY & ORDER BY - Ranking by job_title_short
select
    job_id,
    job_title_short,
    salary_hour_avg,
    rank() over (
        partition by job_title_short
        order by salary_hour_avg desc
    ) as rank
from
    job_postings_fact
where 
    salary_hour_avg is not null
order by 
    salary_hour_avg desc,
    job_title_short
limit 10;

-- Ranking Functions - RANK() vs DENSE_RANK()
select
    job_id,
    job_title_short,
    salary_hour_avg,
    dense_rank() over (
        order by salary_hour_avg desc
    ) as rank
from
    job_postings_fact
where 
    salary_hour_avg is not null
order by 
    salary_hour_avg desc
limit 140;

-- ROW_NUMBER() - Providing a new job_id
select
    *,
    row_number() over (
        order by job_posted_date
    )
from 
    job_postings_fact
order by 
    job_posted_date
limit 20;

-- LAG() - Time Based Comparison of Company Yearly Salary
select
    job_id,
    company_id,
    job_title,
    job_title_short,
    job_posted_date,
    salary_year_avg,
    lead(salary_year_avg) over (
        partition by company_id
        order by job_posted_date
    ) as next_posting_salary,
    salary_year_avg - lead(salary_year_avg) over (
        partition by company_id
        order by job_posted_date
    ) as salary_change
from
    job_postings_fact
where salary_year_avg is not null
order by company_id, job_posted_date
limit 60;