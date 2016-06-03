INSERT INTO Publishers(id, name, note)
SELECT pb.id, pb.name, n.note
FROM Publishers_temp pb, Notes n
WHERE n.id = pb.note_id
UNION
SELECT id, name, NULL
FROM Publishers_temp
WHERE note_id IS NULL
;

