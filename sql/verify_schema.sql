-- Structure checks for Smart Placement Management System.
-- These queries read database metadata without changing our tables.

-- Check 1: Confirm the connected database.
SELECT current_database();

-- Check 2: List our tables.
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Check 3: Count the four constraint types used in our design.
SELECT
    CASE c.contype
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'c' THEN 'CHECK'
    END AS constraint_type,
    COUNT(*) AS constraint_count
FROM pg_catalog.pg_constraint AS c
JOIN pg_catalog.pg_class AS t
    ON t.oid = c.conrelid
JOIN pg_catalog.pg_namespace AS n
    ON n.oid = t.relnamespace
WHERE n.nspname = 'public'
  AND t.relkind = 'r'
  AND c.contype IN ('p', 'f', 'u', 'c')
GROUP BY c.contype
ORDER BY constraint_type;