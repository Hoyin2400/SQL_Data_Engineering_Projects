-- Subquery
select *
from (
    select *
    from job_postings_fact
    where salary_year_avg is not null
        or salary_hour_avg is not null
) as valid_salaries
limit 10;

-- CTE
with valid_salaries as (
    select *
    from job_postings_fact
    where salary_year_avg is not null
        or salary_hour_avg is not null
)
select *
from valid_salaries
limit 10;

-- Scenario 1 - Subquery in `SELECT`
-- Show each job's salary next to the overall market median:
select
    job_title_short,
    salary_year_avg,
    (
        select median(salary_year_avg)
        from job_postings_fact
    ) as market_median_salary
from job_postings_fact
where salary_year_avg is not null
limit 10;

-- Scenario 2 - Subquery in FROM
-- Stage only jobs that are remote before aggregating to determine the remote median 
-- salary per job
select
    job_title_short,
    median(salary_year_avg) as median_salary,
    (
        select median(salary_year_avg)
        from job_postings_fact
        where job_work_from_home = true
    ) as market_remote_median_salary
from (
    select
        job_title_short,
        salary_year_avg
    from job_postings_fact
    where job_work_from_home = true
)
where salary_year_avg is not null
group by job_title_short
limit 10;

-- Scenario 3 - Subquery in HAVING
-- Keep only job titles whose median salary is above the overall median:
select
    job_title_short,
    median(salary_year_avg) as median_salary,
    (
        select median(salary_year_avg)
        from job_postings_fact
        where job_work_from_home = true
    ) as market_remote_median_salary
from (
    select
        job_title_short,
        salary_year_avg
    from job_postings_fact
    where job_work_from_home = true
)
where salary_year_avg is not null
group by job_title_short
having median(salary_year_avg) > (
    select median(salary_year_avg)
    from job_postings_fact
    where job_work_from_home = true
)
limit 10;

-- CTE Example
-- Compare how much more (or less) remote roles pay compared to onsite roles for each job title.
-- Use a CTE to calculate the median salary by title and work arrangement, then compare those medians
with title_median as (
    select 
        job_title_short,
        job_work_from_home,
        median(salary_year_avg)::int as median_salary
    from job_postings_fact
    where job_country = 'Canada'
    group by
        job_title_short,
        job_work_from_home
)
select 
    r.job_title_short,
    r.median_salary as remote_median_salary,
    o.median_salary as onsite_median_salary,
    (r.median_salary - o.median_salary) as remote_premium
from title_median as r
inner join title_median as o
    on r.job_title_short = o.job_title_short
where r.job_work_from_home = true
    and o.job_work_from_home = false
order by remote_premium desc;


select *
from range(3) as src(key);

select *
from range(2) as tgt(key);



-- Final Example
-- Identify job postings that have no associated skills before loading them into a data mart
select *
from job_postings_fact
order by job_id
limit 10;

select *
from skills_job_dim
order by job_id
limit 40;

select *
from job_postings_fact jpf
where not exists (
    select 1
    from skills_job_dim sjd
    where jpf.job_id = sjd.job_id
)
order by job_id;
