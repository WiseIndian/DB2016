INSERT INTO Publication_Series(id, name, note)
SELECT pb_s.id, name, note
FROM Publication_Series_temp pb_s, Notes n
WHERE pb_s.note_id = n.id
UNION
SELECT id, name, NULL
FROM Publication_Series_temp
WHERE note_id IS NULL
;

