create schema if not exists audit;

create table audit.history
(
    event_id         bigserial primary key,
    ts               timestamp default now(),
    client_addr      inet,
    client_port      int,
    schema_name      text not null,
    table_name       text not null,
    operation        text not null,
    user_name        text,
    application_name text,
    query            text,
    row_id           text,
    row              jsonb not null,
    changes          jsonb
);

create index history_row_id_idx on audit.history(row_id);

comment on table audit.history is 'History of operations on audited tables from audit.change_trigger() trigger function.';
comment on column audit.history.event_id is 'Unique identifier for each audit row';
comment on column audit.history.ts is 'Timestamp when the audit row was inserted';
comment on column audit.history.client_addr is 'IP address of the client that issued the query';
comment on column audit.history.client_addr is 'Port of the client that issued the query';
comment on column audit.history.schema_name is 'Database schema of the audited row';
comment on column audit.history.table_name is 'Table name of the audited row';
comment on column audit.history.operation is 'Operation: INSERT, UPDATE, or DELETE';
comment on column audit.history.user_name is 'Session user whose statement caused the row to be audited';
comment on column audit.history.application_name is 'Application name that was set when the row was audited';
comment on column audit.history.query is 'Query that caused the row to be audited';
comment on column audit.history.row_id is 'Likely audited row primary key';
comment on column audit.history.row is 'Record value';
comment on column audit.history.changes is 'New values of fields changed by UPDATE operations. null for INSERT and DELETE';

create or replace function audit.change_trigger() returns trigger as
$$
begin
    if tg_op = 'INSERT'
    then
        insert into audit.history (client_addr, client_port, schema_name, table_name, operation, user_name,
                                   application_name, query, row, row_id)
        values (inet_client_addr(), inet_client_port(), tg_table_schema, tg_table_name, tg_op, session_user::text,
                current_setting('application_name'), current_query(), row_to_json(new), new.id::text);
        return new;
    elsif tg_op = 'UPDATE'
    then
        insert into audit.history (client_addr, client_port, schema_name, table_name, operation, user_name,
                                   application_name, query, row, changes, row_id)
        values (inet_client_addr(), inet_client_port(), tg_table_schema, tg_table_name, tg_op, session_user::text,
                current_setting('application_name'), current_query(),
                row_to_json(old), (select jsonb_object_agg(tmp_new_row.key, tmp_new_row.value)
                                   from jsonb_each_text(row_to_json(new)::jsonb) as tmp_new_row
                                            join jsonb_each_text(row_to_json(old)::jsonb) as tmp_old_row
                                                 on (tmp_new_row.key = tmp_old_row.key and
                                                     tmp_new_row.value is distinct from tmp_old_row.value)),
                new.id::text);
        return new;
    elsif tg_op = 'DELETE'
    then
        insert into audit.history (client_addr, client_port, schema_name, table_name, operation, user_name,
                                   application_name, query, row, row_id)
        values (inet_client_addr(), inet_client_port(), tg_table_schema, tg_table_name, tg_op, session_user::text,
                current_setting('application_name'),
                current_query(),
                row_to_json(old), old.id::text);
        return old;
    end if;
end;
$$ language 'plpgsql' security definer;