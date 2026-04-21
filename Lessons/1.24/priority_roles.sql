create or replace table staging.priority_roles (
    role_id integer primary key,
    role_name varchar,
    priority_lvl integer
);

insert into staging.priority_roles (role_id, role_name, priority_lvl)
values
    (1, 'Data Engineer', 2),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer', 3);

select * from staging.priority_roles;