-- Inspect existing indexes in the public schema.
-- Read-only: does not create or modify indexes.

SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY
    tablename,
    indexname;