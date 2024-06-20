create schema if not exists audit_test;

create table audit_test.customers
(
    id    text primary key,
    name  text,
    email text,
    score int
);

create trigger audit_trigger
    after insert or update or delete
    on audit_test.customers
    for each row
execute procedure audit.change_trigger();

create table audit_test.addresses
(
    id     serial primary key,
    street text
);

create trigger audit_trigger
    after insert or update or delete
    on audit_test.addresses
    for each row
execute procedure audit.change_trigger();

insert into audit_test.customers (id, name, email, score)
VALUES ('abc', 'Vincent', 'vincent@example.com', 42),
       ('def', 'Sabine', 'sabine@example.com', 42);

update audit_test.customers
set score = 100
where id = 'abc';

update audit_test.customers
set email = 'sabine+test@example.com',
    score = 50
where id = 'def';

delete
from audit_test.customers
where id = 'abc';

insert into audit_test.addresses (street)
VALUES ('Bernauer Str.'),
       ('Alice-und-Hella-Hirsch-Ring');

select *
from audit.history;
