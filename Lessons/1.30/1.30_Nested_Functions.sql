-- Array Intro
select ['python', 'sql', 'r'] as skills_array;

with skills as (
    select 'python' as skill
    union all
    select 'sql'
    union all
    select 'r'
), skills_array as (
    select array_agg(skill order by skill) as skills
    from skills
)
select
    skills[1] as first_skill,
    skills[2] as second_skill,
    skills[3] as third_skill
from skills_array;

-- STRUCT
select { skill: 'python', type: 'programming' } as skill_struct;

with skill_struct as (
    select
    struct_pack(
        skill := 'python',
        type := 'programming'
    ) as s
)
select
    s.skill,
    s.type
from skill_struct;

with skill_table as (
    select 'python' as skills, 'programming' as types
    union all
    select 'sql', 'query_langauge'
    union all
    select 'r', 'programming' 
)
select
    struct_pack(
        skill := skills,
        type := types
    )
from skill_table;


-- Array of Structs
select [
    { skill: 'python', type: 'programming' },
    { skill: 'sql', type: 'query_language' }
] as skills_array_of_structs:


with skill_table as (
    select 'python' as skills, 'programming' as types
    union all
    select 'sql', 'query_langauge'
    union all
    select 'r', 'programming' 
), skills_array_struct as (
    select
        array_agg(
            struct_pack(
                skill := skills,
                type := types
            )        
        ) as array_struct
    from skill_table
)
select
    array_struct[1].skill,
    array_struct[2].type,
    array_struct[3]    
from skills_array_struct;



-- MAP
with skill_map as (
    select map {'skill' : 'python', 'type': 'programming'} as skill_type
)
select
    skill_type['skill'],
    skill_type['type']
from 
    skill_map;


-- JSON
with raw_skill_json as (
    select
        '{"skill":"python", "type":"programming"}'::json as skill_json
)
select
    struct_pack(
        skill := json_extract_string(skill_json, '$.skill'),
        type := json_extract_string(skill_json, '$.type')
    )
from raw_skill_json;


-- JSON to Array of Structs
with raw_json as (
select
    '[
        {"skill":"python","type":"programming"},
        {"skill":"sql","type":"query_language"},
        {"skill":"r","type":"programming"}
    ]'::json as skills_json
)
select 
    array_agg(
        struct_pack(
            skill := json_extract_string(e.value, '$.skill'),
            type := json_extract_string(e.value, '$.type')
        )
        order by json_extract_string(e.value, '$.skill')
    ) as skills
from raw_json, json_each(skills_json) as e;

with raw_json as (
select
    '[
        {"skill":"python","type":"programming"},
        {"skill":"sql","type":"query_language"},
        {"skill":"r","type":"programming"}
    ]'::json as skills_json
)
from json_each


-- Arrays - Final Example
-- Build a flat skill table for co-workers to access job titles, salary info, and skills in one table

-- job_title, salary_year_avg/salary_hour_avg, 

select salary_rate
from job_postings_fact as jpf;

create or replace temp table job_skills_array as
select 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    array_agg(sd.skills) as skills_array
from job_postings_fact as jpf
left join skills_job_dim as sjd
    on jpf.job_id = sjd.job_id
left join skills_dim as sd
    on sjd.skill_id = sd.skill_id
where jpf.salary_year_avg is not null
group by 
    jpf.job_id, 
    jpf.job_title_short, 
    salary_year_avg;

-- From the perspective of a Data Analyst, analyze the median salary per skill

with skills_table as (
    select
        job_id,
        job_title_short,
        salary_year_avg,
        unnest(skills_array) as skill
    from job_skills_array
    where salary_year_avg is not null
)
select
    skill,
    median(salary_year_avg)
from skills_table
group by skill
order by median(salary_year_avg) desc;

-- Array of Structs - Final Example
-- Build a flat skill & type table for co-workers to access job titles, salary info, skills, and type in one table

create or replace temp table job_skills_array_struct as
select 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    array_agg(
        struct_pack(
            skill_name := sd.skills,
            skill_type := sd.type                     
        )
    ) as skills_type
from job_postings_fact as jpf
left join skills_job_dim as sjd
    on jpf.job_id = sjd.job_id
left join skills_dim as sd
    on sjd.skill_id = sd.skill_id
group by 
    jpf.job_id, 
    jpf.job_title_short, 
    salary_year_avg;

-- From the perspective of a Data Analyst, analyze the median salary per type of skill
with flat_job_skills as (
    select
        job_id,
        job_title_short,
        salary_year_avg,
        unnest(skills_type).skill_type as skill_type,
        unnest(skills_type).skill_name as skill_name
    from
        job_skills_array_struct
)
select
    skill_type,
    median(salary_year_avg)
from
    flat_job_skills
group by skill_type
order by median(salary_year_avg) desc;