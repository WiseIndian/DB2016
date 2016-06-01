INSERT INTO Publishers(id, name, note)
SELECT pb.id, name, note
FROM Publishers_temp pb, Notes n
WHERE n.id = pb.note_id
UNION
SELECT id, name, NULL
FROM Publishers_temp
WHERE n.id IS NULL
;

