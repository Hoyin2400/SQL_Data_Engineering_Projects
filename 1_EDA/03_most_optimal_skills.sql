/*
Question: What are the most optimal skills for data engineers?
- Create a ranking column that combines demand count and median salary to
identify the most valuable skills
- Focus only on Canadian Data Engineer positions with specified annual salaries
- Why?
    - This approach highlights skills that balance market demand and financial.
    reward. It weights core skills appropriately, rather than letting rare,
    outlier skills distort the results.
*/

select
    sd.skills,
    cast(median(jpf.salary_year_avg) as int) as median_salary,
    count(*) as num_postings,
    round(ln(count(*)), 1) as ln_num_postings,
    round(median(jpf.salary_year_avg) * ln(count(*)) / 1_000_000, 2) as optimal_score
from job_postings_fact jpf
inner join skills_job_dim sjd
    on jpf.job_id = sjd.job_id
inner join skills_dim sd  
    on sjd.skill_id = sd.skill_id
where 
    jpf.job_title_short = 'Data Engineer' 
    and jpf.job_country = 'Canada'
    and jpf.salary_year_avg is not null
group by 
    sd.skills
order by optimal_score desc
limit 25;

/*

When attempting to combine the effects of median salary and number of postings,
the number of postings had a disproportional effect on the optimal score. To
make the effect of the number of postings more linear, the natural log (ln) was
applied before calculating natural score.

Observations:
- AWS had the best balance of salary and number of postings
- Languages like Python, SQL, and Java all appeared in the top 5
- The top data platforms were Snowflake, Spark, Airflow, Redshift, and Databricks,
all appearing in the top 10
- Azure and GCP placed 9th and 11th respectively, both comparatively lower than AWS

┌────────────┬───────────────┬──────────────┬─────────────────┬───────────────┐
│   skills   │ median_salary │ num_postings │ ln_num_postings │ optimal_score │
│  varchar   │     int32     │    int64     │     double      │    double     │
├────────────┼───────────────┼──────────────┼─────────────────┼───────────────┤
│ aws        │        125000 │          122 │             4.8 │           0.6 │
│ python     │        110000 │          169 │             5.1 │          0.56 │
│ sql        │        110000 │          170 │             5.1 │          0.56 │
│ snowflake  │        125000 │           67 │             4.2 │          0.53 │
│ java       │        125000 │           62 │             4.1 │          0.52 │
│ spark      │        115000 │           89 │             4.5 │          0.52 │
│ airflow    │        125000 │           55 │             4.0 │           0.5 │
│ redshift   │        125000 │           45 │             3.8 │          0.48 │
│ azure      │        106200 │           88 │             4.5 │          0.48 │
│ databricks │        125000 │           44 │             3.8 │          0.47 │
│ gcp        │        125000 │           40 │             3.7 │          0.46 │
│ kafka      │        113058 │           58 │             4.1 │          0.46 │
│ hadoop     │        115558 │           50 │             3.9 │          0.45 │
│ scala      │        117500 │           42 │             3.7 │          0.44 │
│ nosql      │        116250 │           40 │             3.7 │          0.43 │
│ kubernetes │        125000 │           29 │             3.4 │          0.42 │
│ mongodb    │        122500 │           24 │             3.2 │          0.39 │
│ bigquery   │        111808 │           32 │             3.5 │          0.39 │
│ excel      │        133000 │           19 │             2.9 │          0.39 │
│ jenkins    │        125000 │           23 │             3.1 │          0.39 │
│ docker     │        110000 │           31 │             3.4 │          0.38 │
│ flow       │        107958 │           30 │             3.4 │          0.37 │
│ jira       │        125000 │           20 │             3.0 │          0.37 │
│ terraform  │        117500 │           22 │             3.1 │          0.36 │
│ git        │        116250 │           22 │             3.1 │          0.36 │
├────────────┴───────────────┴──────────────┴─────────────────┴───────────────┤
│ 25 rows                                                           5 columns │
└─────────────────────────────────────────────────────────────────────────────┘
*/


select
    sd.skills,
    cast(median(jpf.salary_year_avg) as int) as median_salary,
    count(*) as num_postings,
    round(median(jpf.salary_year_avg) * count(*) / 1_000_000, 2) as optimal_score
from job_postings_fact jpf
inner join skills_job_dim sjd
    on jpf.job_id = sjd.job_id
inner join skills_dim sd  
    on sjd.skill_id = sd.skill_id
where 
    jpf.job_title_short = 'Data Engineer' 
    and jpf.job_country = 'Canada'
    and jpf.salary_year_avg is not null
group by 
    sd.skills
order by optimal_score desc
limit 25;

/*
Optimal score is very correlated with number of postings when only multiplying
the salary and postings numbers.

┌────────────┬───────────────┬──────────────┬───────────────┐
│   skills   │ median_salary │ num_postings │ optimal_score │
│  varchar   │     int32     │    int64     │    double     │
├────────────┼───────────────┼──────────────┼───────────────┤
│ sql        │        110000 │          170 │          18.7 │
│ python     │        110000 │          169 │         18.59 │
│ aws        │        125000 │          122 │         15.25 │
│ spark      │        115000 │           89 │         10.24 │
│ azure      │        106200 │           88 │          9.35 │
│ snowflake  │        125000 │           67 │          8.38 │
│ java       │        125000 │           62 │          7.75 │
│ airflow    │        125000 │           55 │          6.88 │
│ kafka      │        113058 │           58 │          6.56 │
│ hadoop     │        115558 │           50 │          5.78 │
│ redshift   │        125000 │           45 │          5.63 │
│ databricks │        125000 │           44 │           5.5 │
│ gcp        │        125000 │           40 │           5.0 │
│ scala      │        117500 │           42 │          4.93 │
│ nosql      │        116250 │           40 │          4.65 │
│ kubernetes │        125000 │           29 │          3.63 │
│ bigquery   │        111808 │           32 │          3.58 │
│ docker     │        110000 │           31 │          3.41 │
│ flow       │        107958 │           30 │          3.24 │
│ tableau    │        100000 │           31 │           3.1 │
│ sql server │        102500 │           30 │          3.08 │
│ pyspark    │        108050 │           28 │          3.03 │
│ mongodb    │        122500 │           24 │          2.94 │
│ power bi   │        100000 │           29 │           2.9 │
│ jenkins    │        125000 │           23 │          2.88 │
├────────────┴───────────────┴──────────────┴───────────────┤
│ 25 rows                                         4 columns │
└───────────────────────────────────────────────────────────┘
*/