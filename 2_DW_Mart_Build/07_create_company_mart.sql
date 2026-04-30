-- Step 7: Mart - Create company mart

DROP SCHEMA IF EXISTS company_mart CASCADE;

CREATE SCHEMA company_mart;

-- Generates IDs for the Job Title Dimension
DROP SEQUENCE IF EXISTS jt_id;
CREATE SEQUENCE jt_id START 1;

-- Job Title Dimension
CREATE TABLE company_mart.dim_job_title (
    job_title_id    INTEGER PRIMARY KEY DEFAULT nextval('jt_id'),
    job_title       VARCHAR
);
INSERT INTO company_mart.dim_job_title (job_title)
-- Select only unique existing job titles
SELECT DISTINCT job_title
FROM job_postings_fact
WHERE job_title IS NOT NULL;

-- Generates IDs for the Job Title Short Dimension
DROP SEQUENCE IF EXISTS jts_id;
CREATE SEQUENCE jts_id START 1;

CREATE TABLE company_mart.dim_job_title_short (
    job_title_short_id      INTEGER PRIMARY KEY DEFAULT nextval('jts_id'),
    job_title_short         VARCHAR
);
INSERT INTO company_mart.dim_job_title_short (job_title_short)
-- Select only unique existing short job titles
SELECT DISTINCT job_title_short
FROM job_postings_fact
WHERE job_title_short IS NOT NULL
GROUP BY job_title_short;

-- Date Month Dimension
CREATE TABLE company_mart.dim_date_month (
    month_start_date    DATE        PRIMARY KEY,
    year                INTEGER,
    month               INTEGER
);

INSERT INTO company_mart.dim_date_month (month_start_date, year, month)
-- Only include unique date combinations
SELECT DISTINCT
    -- First day of the month when the job was posted  
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT(year FROM job_posted_date) AS year,
    EXTRACT(month FROM job_posted_date) AS month
FROM job_postings_fact
WHERE job_posted_date IS NOT NULL
ORDER BY month_start_date;

-- Location Dimension
DROP SEQUENCE IF EXISTS loc_id;
CREATE SEQUENCE loc_id START 1;

CREATE TABLE company_mart.dim_location (
    location_id     INTEGER     PRIMARY KEY DEFAULT nextval('loc_id'),
    job_country     VARCHAR,
    job_location    VARCHAR
);

INSERT INTO company_mart.dim_location (job_country, job_location)
-- Select unique combinations of country and location
SELECT DISTINCT
    job_country,
    job_location
FROM job_postings_fact
WHERE job_country IS NOT NULL 
    AND job_location IS NOT NULL;

-- Company Dimension
CREATE TABLE company_mart.dim_company (
    company_id      INTEGER     PRIMARY KEY,
    company_name    VARCHAR
);

INSERT INTO company_mart.dim_company (company_id, company_name)
SELECT
    company_id,
    name AS company_name
FROM company_dim;

-- Bridge Table: Company to Location (many-to-many)
-- Shows which companies hire in which locations
CREATE TABLE company_mart.bridge_company_location (
    company_id      INTEGER,
    location_id     INTEGER,
    PRIMARY KEY (company_id, location_id),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (location_id) REFERENCES company_mart.dim_location(location_id)
);

INSERT INTO company_mart.bridge_company_location (company_id, location_id)
SELECT DISTINCT
    company_id,
    location_id
FROM job_postings_fact jpf
INNER JOIN company_mart.dim_location loc
    ON jpf.job_country = loc.job_country
    AND jpf.job_location = loc.job_location
WHERE jpf.company_id IS NOT NULL;

-- Bridge Table: Job Title Short to Job Title
-- Shows all job titles associated with each job_title_short
CREATE TABLE company_mart.bridge_job_title (
    job_title_short_id      INTEGER,
    job_title_id            INTEGER,
    PRIMARY KEY (job_title_short_id, job_title_id),
    FOREIGN KEY (job_title_short_id)
        REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (job_title_id)
        REFERENCES company_mart.dim_job_title(job_title_id)
);

INSERT INTO company_mart.bridge_job_title (job_title_short_id, job_title_id)
SELECT DISTINCT
    job_title_short_id,
    job_title_id
FROM job_postings_fact jpf
INNER JOIN company_mart.dim_job_title jt
    ON jpf.job_title = jt.job_title
INNER JOIN company_mart.dim_job_title_short jts
    ON jpf.job_title_short = jts.job_title_short;

-- Company Hiring Monthly Fact Table
-- Grain: company_id + job_title_short_id + job_country + month_start_date
CREATE TABLE company_mart.fact_company_hiring_monthly (
    company_id                  INTEGER,
    job_title_short_id          INTEGER,
    job_country                 VARCHAR,
    month_start_date            DATE,
    postings_count              INTEGER,
    median_salary_year          INTEGER,
    min_salary_year             INTEGER,
    remote_share                DOUBLE,
    health_insurance_share      DOUBLE,
    no_degree_mention_share     DOUBLE,
    PRIMARY KEY (company_id, job_title_short_id, month_start_date, job_country),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (month_start_date) REFERENCES company_mart.dim_date_month(month_start_date)
);

INSERT INTO company_mart.fact_company_hiring_monthly (
    company_id,             
    job_title_short_id,     
    job_country,            
    month_start_date,       
    postings_count,         
    median_salary_year,     
    min_salary_year,        
    remote_share,           
    health_insurance_share, 
    no_degree_mention_share
)
WITH job_postings_processed AS (
    SELECT
        jpf.company_id,             
        jts.job_title_short_id,     
        DATE_TRUNC('month', jpf.job_posted_date) AS month_start_date,       
        jpf.job_country,                   
        jpf.salary_year_avg,     
        CASE WHEN jpf.job_work_from_home IS TRUE THEN 1 ELSE 0 END AS is_remote,
        CASE WHEN jpf.job_health_insurance IS TRUE THEN 1 ELSE 0 END AS has_health_insurance,
        CASE WHEN jpf.job_no_degree_mention IS TRUE THEN 1 ELSE 0 END AS no_degree_mentioned,
    FROM job_postings_fact jpf
    INNER JOIN company_mart.dim_job_title_short jts
        ON jpf.job_title_short = jts.job_title_short
    WHERE
        jpf.job_country IS NOT NULL
        AND jpf.salary_year_avg IS NOT NULL
)
SELECT
    company_id,             
    job_title_short_id,     
    job_country,            
    month_start_date,       
    COUNT(*) AS postings_count,         
    MEDIAN(salary_year_avg) AS median_salary_year,     
    MIN(salary_year_avg) AS min_salary_year,
    -- Proportion of job postings that are remote (0 = none, 1 = all)
    ROUND(AVG(is_remote), 3) AS remote_share,
    -- Proportion of job postings that have health insurance (0 = none, 1 = all)
    ROUND(AVG(has_health_insurance), 3) AS health_insurance_share,
    -- Proportion of job postings that don't mention a degree (0 = none, 1 = all)
    ROUND(AVG(no_degree_mentioned), 3) AS no_degree_mention_share,
FROM job_postings_processed jpp
GROUP BY
    company_id,
    job_title_short_id,
    job_country,
    month_start_date;    

-- Data Validation
SELECT 'Job Title Short Dimension' AS table_name, COUNT(*) AS record_count FROM company_mart.dim_job_title_short
UNION ALL
SELECT 'Job Title Dimension', COUNT(*) FROM company_mart.dim_job_title
UNION ALL
SELECT 'Job Title Bridge', COUNT(*) FROM company_mart.bridge_job_title
UNION ALL
SELECT 'Company Dimension' AS table_name, COUNT(*) AS record_count FROM company_mart.dim_company
UNION ALL
SELECT 'Location Dimension', COUNT(*) FROM company_mart.dim_location
UNION ALL
SELECT 'Date Month Dimension', COUNT(*) FROM company_mart.dim_date_month
UNION ALL
SELECT 'Company Location Bridge', COUNT(*) FROM company_mart.bridge_company_location
UNION ALL
SELECT 'Company Hiring Monthly Fact', COUNT(*) FROM company_mart.fact_company_hiring_monthly;

SELECT '=== Job Title Short Dimension ===' AS info;
SELECT * FROM company_mart.dim_job_title_short LIMIT 5;

SELECT '=== Job Title Dimension ===' AS info;
SELECT * FROM company_mart.dim_job_title LIMIT 5;

SELECT '=== Job Title Bridge ===' AS info;
SELECT * FROM company_mart.bridge_job_title LIMIT 5;

SELECT '=== Company Dimension ===' AS info;
SELECT * FROM company_mart.dim_company LIMIT 5;

SELECT '=== Location Dimension ===' AS info;
SELECT * FROM company_mart.dim_location LIMIT 5;

SELECT '=== Date Month Dimension ===' AS info;
SELECT * FROM company_mart.dim_date_month LIMIT 5;

SELECT '=== Company Location Bridge ===' AS info;
SELECT * FROM company_mart.bridge_company_location LIMIT 5;

SELECT '=== Company Hiring Monthly Fact ===' AS info;
SELECT * FROM company_mart.fact_company_hiring_monthly LIMIT 5;
