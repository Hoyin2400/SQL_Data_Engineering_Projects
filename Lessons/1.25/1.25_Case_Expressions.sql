-- Bucket Salaries
-- < 25  = 'Low'
-- 25-50 = 'Medium'
-- > 50  = 'High'

select
    job_title_short,
    salary_hour_avg,
    case
        when salary_hour_avg < 25 then 'Low'
        when salary_hour_avg < 50 then 'Medium'
        else 'High'
    end as salary_category
from job_postings_fact
where salary_hour_avg is not null
limit 10;

-- Handling Missing Data (Nulls)
-- Filter NULL salary values

select
    job_title_short,
    salary_hour_avg,
    case
        when salary_hour_avg is null then 'Missing'    
        when salary_hour_avg < 25 then 'Low'
        when salary_hour_avg < 50 then 'Medium'
        else 'High'
    end as salary_category
from job_postings_fact
limit 10;

-- Categorizing Categorical Values
-- Classify the `job_title` column values as:
    -- 'Data Analyst'
    -- 'Data Engineer'
    -- 'Data Scientist'

select
    job_title,
    case
        when lower(job_title) like '%data%' 
            and lower(job_title) like '%analyst%' then 'Data Analyst'
        when lower(job_title) like '%data%' 
            and lower(job_title) like '%engineer%' then 'Data Engineer'
        when lower(job_title) like '%data%' 
            and lower(job_title) like '%scientist%' then 'Data Scientist'
        else 'Other'
    end as job_title_category,
    job_title_short
from job_postings_fact
order by random()
limit 20;

-- Conditional Aggregation
-- Calculate Median Salaries for Different Buckets
    -- < $100K
    -- >= $100K

select
    job_title_short,
    count(*) as total_postings,
    median(
        case   
            when salary_year_avg < 100_000 then salary_year_avg
        end
    ) as median_low_salary,
    median(
        case   
            when salary_year_avg >= 100_000 then salary_year_avg
        end
    ) as median_high_salary
from job_postings_fact
where salary_year_avg is not null
group by job_title_short;


-- Final Example: Conditional Calculations
-- Compute a standardized_salary using yearly salary and adjusted hourly salary (e.g. 2080 hours/year)
-- Categorize salaries into tiers of:
    -- < 75K 'Low'
    -- 75K - 150K 'Medium'
    -- >= 150K 'High'

with salaries as (
    select
        job_title_short,
        salary_hour_avg,
        salary_year_avg,
        case
            when salary_year_avg is not null then salary_year_avg
            when salary_hour_avg is not null then salary_hour_avg * 2080
        end as standardized_salary
    from
        job_postings_fact
)
select
    *,
    case
        when standardized_salary is null then 'Missing'
        when standardized_salary < 75_000 then 'Low'
        when standardized_salary < 150_000 then 'Medium'
        else 'High'
    end as salary_bucket
from salaries
limit 10;