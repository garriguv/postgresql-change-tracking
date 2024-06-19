create table test
(
    id    int primary key,
    value text,
    count int
);

create trigger audit_trigger
    after insert
        or
        update
        or
        delete
    on test
    for each row
execute procedure audit.change_trigger();

create table other_test
(
    id    text primary key,
    value text
);

create trigger audit_trigger
    after insert or update or delete
    on other_test
    for each row
execute procedure audit.change_trigger();