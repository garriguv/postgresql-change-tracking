select audit.strip_context('update test /*_audit {"key": "value"} _audit*/ set value =') = 'update test set value =',
       audit.strip_context('update test set value =') = 'update test set value =',
       audit.strip_context('update test /*_audit  _audit*/ set value =') = 'update test set value =',
       audit.extract_context('update test /*_audit {"key": "value"} _audit*/ set value =') = '{
         "key": "value"
       }'::jsonb,
       audit.extract_context('update test set value =') is null,
       audit.extract_context('update test /*_audit  _audit*/ set value =') is null,
       audit.extract_context('update test /*_audit {} _audit*/ set value =') = '{}'::jsonb;
