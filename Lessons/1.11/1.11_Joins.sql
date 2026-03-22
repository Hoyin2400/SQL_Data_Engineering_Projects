-- Get the most common skills from all job postings
-- Join skill to postings, get count, order by skills desc

select 
    sd.skills,
    count(*) as '# of Jobs'
from 
    job_postings_fact jpf
    left join skills_job_dim sjd
        on jpf.job_id = sjd.job_id
    left join skills_dim sd
        on sjd.skill_id = sd.skill_id
group by sd.skills
order by count(*) desc;

-- Alternative looking for most common types

select 
    sd.type,
    count(*) as '# of Jobs'
from 
    job_postings_fact jpf
    left join skills_job_dim sjd
        on jpf.job_id = sjd.job_id
    left join skills_dim sd
        on sjd.skill_id = sd.skill_id
group by sd.type
order by count(*) desc;

-- look at NULLS for info


select 
    jpf.job_title,
    sd.skills,
    sd.type
from 
    job_postings_fact jpf
    left join skills_job_dim sjd
        on jpf.job_id = sjd.job_id
    left join skills_dim sd
        on sjd.skill_id = sd.skill_id
where type is null
limit 100;

-- Probably skills were not included in the post

-- Find number of skills per post

select
    jpf.job_id,
    jpf.job_title_short,
    sjd.skill_id,
    sd.skills
from 
    job_postings_fact jpf
    left join skills_job_dim sjd
        on jpf.job_id = sjd.job_id
    left join skills_dim sd
        on sjd.skill_id = sd.skill_id
limit 10;

-- find most needed skills by job

select
    jpf.job_title_short as 'short job title',
    sd.skills as 'skill',
    count(*) as '# of jobs'
from 
    job_postings_fact jpf
    left join skills_job_dim sjd
        on jpf.job_id = sjd.job_id
    left join skills_dim sd
        on sjd.skill_id = sd.skill_id
group by jpf.job_title_short, sd.skills
order by jpf.job_title_short desc, count(*) desc;

-- inner join (10 less rows)

select
    jpf.job_title_short as 'short job title',
    sd.skills as 'skill',
    count(*) as '# of jobs'
from 
    job_postings_fact jpf
    inner join skills_job_dim sjd
        on jpf.job_id = sjd.job_id
    inner join skills_dim sd
        on sjd.skill_id = sd.skill_id
group by jpf.job_title_short, sd.skills
order by jpf.job_title_short desc, count(*) desc;