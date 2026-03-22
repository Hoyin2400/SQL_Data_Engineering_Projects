/*
Question: What are the most in-demand skills for data engineers
- Identify the top 10 in-demand skills for data engineers
- Focus on job postings in Canada
- Why? Provides insights into the most valuable skills for data engineers 
in Canada
*/

select
    sd.skills,
    count(*) as 'Number of Postings'
from job_postings_fact jpf
inner join skills_job_dim sjd
    on jpf.job_id = sjd.job_id
inner join skills_dim sd  
    on sjd.skill_id = sd.skill_id
where 
    job_title_short = 'Data Engineer' 
    and job_country = 'Canada'
group by 
    sd.skills
order by   
    count(*) desc
limit 10;

/*
Observations:
- SQL and Python are the most common skills at 1st and 2nd, with significantly 
more postings than other skills in the top 10
- Java and Scala are also commonly sought after languages, but less so than SQL
or Python
- Azure and AWS are the most common cloud platforms found in postings
- Other tools like Apache Spark and Databricks for data processing, Snowflake for 
data warehousing, and Apache Airflow for pipeline management are also included 
in the top 10


┌────────────┬────────────────────┐
│   skills   │ Number of Postings │
│  varchar   │       int64        │
├────────────┼────────────────────┤
│ sql        │               9345 │
│ python     │               8967 │
│ azure      │               5327 │
│ aws        │               5037 │
│ spark      │               4454 │
│ databricks │               3235 │
│ snowflake  │               2985 │
│ java       │               2740 │
│ airflow    │               2396 │
│ scala      │               2255 │
├────────────┴────────────────────┤
│ 10 rows               2 columns │
└─────────────────────────────────┘
*/
    
    