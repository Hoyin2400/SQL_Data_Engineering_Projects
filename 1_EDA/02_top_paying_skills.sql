/*
Question: What are the highest-paying skills for data engineres?
- Calculate the median salary for each skill required in data engineer positions
- Focus on positions in Canada with specified salaries
- Include skill frequency to identify both salary and demand
- Why?
    - Helps identify which skills command the highest compensation while also 
    showing how common those skills are, providing a more complete picture for 
    skill develpment priorities 
*/

select
    sd.skills,
    cast(median(jpf.salary_year_avg) as int) as median_salary,
    count(*) as num_postings
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
having
    count(*) >= 100
order by
    median_salary desc,
    num_postings desc
limit 25;

/*
Observations:
- The highest median salaries were DAX ($155,904, 134 postings), 
Ruby ($147,500, 366 postings), and Node.js ($140,500, 117 postings)
- Machine learning tools like TensorFlow ($140000, 211 postings) and 
PyTorch ($140000, 216 postings) also had relatively high median salaries 
and fewer postings
  
- Core data and analytics tools like PostgreSQL ($136,250, 830 postings) and 
Excel ($133,000, 697 postings) were still somewhat common and offered 
relatively high salaries
- Cassandra (294), Elasticsearch (212), Spring (225) fell in the $130K–$138K 
range with 100-300 postings.

Many skills had median salaries of $125,000 and had over 1000 postings:
	- Cloud platforms: AWS (5,037 postings) and GCP (2,221 postings)
	- Data platforms: Databricks (3,235 postings), Snowflake (2,985 postings), 
      Airflow (2,396 postings), Redshift (1,436 postings), 
      Kubernetes (1,264 postings)
	- Core languages/tools: Java (2,740 postings)

- The most demanded skills had a salary of $125,000 and thousands of postings, 
but many other less demanded skills had a higher median salary and less than 300
postings. This combination of higher salary and lower demand could be due to 
these skills being niche or more difficult compared to other skills.

Takeaway:
Even though there are many higher paying skills with fewer postings, more 
commonly asked for skills like AWS, Databricks, Snowflake, Java, Airflow, GCP, 
Redshift, and Kubernetes all still offer solid salaries. This makes these skills
very appealing, as they offer a good balance of salary and demand in the 
Canadian data engineer market.

┌───────────────┬───────────────┬──────────────┐
│    skills     │ median_salary │ num_postings │
│    varchar    │     int32     │    int64     │
├───────────────┼───────────────┼──────────────┤
│ dax           │        155904 │          134 │
│ ruby          │        147500 │          366 │
│ node.js       │        140500 │          117 │
│ pytorch       │        140000 │          216 │
│ tensorflow    │        140000 │          211 │
│ cassandra     │        138750 │          294 │
│ postgresql    │        136250 │          830 │
│ excel         │        133000 │          697 │
│ spring        │        130000 │          225 │
│ elasticsearch │        130000 │          212 │
│ golang        │        130000 │          141 │
│ unity         │        127500 │          138 │
│ t-sql         │        127250 │          347 │
│ looker        │        125500 │          458 │
│ aws           │        125000 │         5037 │
│ databricks    │        125000 │         3235 │
│ snowflake     │        125000 │         2985 │
│ java          │        125000 │         2740 │
│ airflow       │        125000 │         2396 │
│ gcp           │        125000 │         2221 │
│ redshift      │        125000 │         1436 │
│ kubernetes    │        125000 │         1264 │
│ jenkins       │        125000 │          836 │
│ go            │        125000 │          798 │
│ jira          │        125000 │          581 │
├───────────────┴───────────────┴──────────────┤
│ 25 rows                            3 columns │
└──────────────────────────────────────────────┘

Notes:
- "golang" and "go" are both listed separately on the list, but they refer to 
  the same language, this suggests a semantic issue with the skills data
*/