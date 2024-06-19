# PostgreSQL change tracking

PostgreSQL change tracking using triggers.

References:

- https://wiki.postgresql.org/wiki/Audit_trigger_91plus
- https://www.cybertec-postgresql.com/en/tracking-changes-in-postgresql/
- https://www.postgresql.org/docs/current/functions-info.html#FUNCTIONS-INFO-SESSION

## Providing context

To provide context, you can add a comment to the SQL statement:

```sql
UPDATE my_table /*_audit {"key":"value"} _audit*/ set change = 'value' where id = 'some:urn'
```

The value between `/*_audit ` and ` _audit*/` will be parsed as `jsonb` and added to the `context` column.

This is inspired by how [Bemi](https://bemi.io) propagates context.
