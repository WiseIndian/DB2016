INSERT INTO Award_Categories(id, name, type_id,
				 category_order, note)
SELECT a_c.id, name, type_id, category_order, note
FROM Award_Categories_temp a_c, Notes n
WHERE note_id = n.id
UNION
SELECT id, name, type_id, category_order, NULL
FROM Award_Categories_temp
WHERE note_id = NULL
;

