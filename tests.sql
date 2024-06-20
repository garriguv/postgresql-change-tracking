select audit.strip_context('update test /*_audit {"key": "value"} _audit*/ set value =') = 'update test  set value =',
       audit.strip_context('update test set value =') = 'update test set value =',
       audit.strip_context('update test /*_audit  _audit*/ set value =') = 'update test  set value =',
       audit.strip_context('update test'||chr(10)||'/*_audit  _audit*/ '||chr(10)||'set value =') = 'update test'||chr(10)||' '||chr(10)||'set value =',
       audit.extract_context('update test /*_audit {"key": "value"} _audit*/ set value =') = '{
         "key": "value"
       }'::jsonb,
       audit.extract_context('update test set value =') is null,
       audit.extract_context('update test /*_audit  _audit*/ set value =') is null,
       audit.extract_context('update test /*_audit {} _audit*/ set value =') = '{}'::jsonb;
