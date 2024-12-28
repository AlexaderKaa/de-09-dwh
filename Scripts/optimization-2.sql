EXPLAIN
SELECT *
FROM my_table mt, my_table_dump mtd
WHERE mt.id < 11 AND mt.id > 0 AND mtd.id > 5 AND mtd.id < 11
LIMIT 50
; 