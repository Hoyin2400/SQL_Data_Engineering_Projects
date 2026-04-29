# Exploratory Data Analysis w/ SQL: Job Market Analysis

![Project 1 Overview](/Images/1_1_Project1_EDA.png)

A SQL project analyzing the data engineer job market using real world job 
posting data. It demonstrates my ability to **write production-quality
analytical SQL, design efficient queries, and turn business questions into
data-driven insights**.

## Executive Summary

If you only have a minute, review these:

- [`01_top_demanded_skills.sql`](01_top_demanded_skills.sql)

- [`02_top_paying_skills.sql`](02_top_paying_skills.sql)

- [`03_most_optimal_skills.sql`](03_most_optimal_skills.sql)

## Problem & Context

Questions asked in this analysis:

- Which skills are **most in-demand** for data engineers in Canada?
- Which skills command the **highest salaries** in Canada?
- What is the optimal skill set **balancing demand and compensation** in Canada?

This project analyzes a data warehouse built using a star schema design. The warehouse structure consists of:

![Data Warehouse](/Images/1_2_Data_Warehouse.png)

- **Fact Table:** `job_postings_fact` - Central table containing job posting details (job titles, locations, salaries, dates, etc.)
- **Dimension Tables:**
    - `company_dim` - Company information linked to job postings
    - `skills_dim` - Skills catalog with skill names and types
- **Bridge Table:** `skills_job_dim` - Resolves the many-to-many relationship between job postings and skills

By querying across these interconnected tables, I extracted insights about skill demand, salary patterns, and optimal skill combinations for data engineering roles.

## Tech Stack

- Query Engine: DuckDB
- Language: SQL
- Data Model: Star schema with fact + dimension + bridge tables
- Development: VS Code for SQL editing, Terminal for DuckDB CLI
- Version Control: Git/GitHub for versioned SQL scripts

## Analysis Overview

### Query Structure
1. [Top Demanded Skills](01_top_demanded_skills.sql) - Identifies the 10 most in-demand skills for Canadian data engineer positions
2. [Top Paying Skills](02_top_paying_skills.sql) - Analyzes the 25 highest-paying skills with salary and demand metrics
3. [Optimal Skills](03_most_optimal_skills.sql) - Calculates an optimal score using natural log of demand combined with median salary to identify the most valuable skills to learn

### Key Insights

- SQL and Python are the most common skills found in Canadian Data Engineer job posts
- Cloud platforms like AWS and Azure are critical for data engineering roles
- Knowledge of analytics engines like Apache Spark and Databricks are also valuable skills that offer strong compensation and high demand


## SQL Skills Demonstrated

### Query Design & Optimization

- **Complex Joins**: Multi-table `INNER JOIN` operations across `job_postings_fact`, `skills_job_dim`, and `skills_dim`
- **Aggregations**: `COUNT()`, `MEDIAN()`, `ROUND()` for statistical analysis
- **Sorting & Limiting**: `ORDER BY` with `DESC` and `LIMIT` for top-N analysis

### Data Analysis Techniques

- **Grouping**: `GROUP BY` for categorical analysis by skill
- **Mathematical Functions**: `LN()` for natural logarithm transformation to normalize demand metrics
- **Calculated Metrics**: Derived optimal score combining log-transformed demand with median salary
- **HAVING Clause**: Filtering aggregated results (skills with >= 100 postings)
- **NULL Handling**: Proper filtering of incomplete records (`salary_year avg IS NOT NULL`)
