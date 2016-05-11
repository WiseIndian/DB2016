INSERT INTO Awards(id, title, aw_date, type_id, category_id, note_id)
SELECT aw.id, title, aw_date, type_id, category_id, note
FROM Awards_temp aw, Notes n
WHERE n.id = note_id
UNION
SELECT id, title, aw_date, type_id, category_id, NULL
FROM Awards_temp
WHERE note_id = NULL
;

