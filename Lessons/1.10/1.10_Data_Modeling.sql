select *
from information_schema.table_constraints
where table_catalog = 'data_jobs';

pragma show_tables;

describe job_postings_fact;

select *
from information_schema.schemata;

pragma database_size;
call pragma_database_size();

describe tables;

describe skills_job_dim;

select 
    constraint_name, 
    table_name, 
    constraint_type
from information_schema.table_constraints
where table_catalog = 'data_jobs';