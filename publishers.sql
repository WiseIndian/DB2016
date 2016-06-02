INSERT INTO Publishers(id, name, note)
SELECT pb.id, pb.name, note
FROM Publishers_temp pb, Notes n
WHERE n.id = pb.note_id
UNION
SELECT pb.id, pb.name, NULL
FROM Publishers_temp pb, Notes n
WHERE n.id IS NULL
;

