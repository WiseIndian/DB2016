INSERT INTO Publishers(id, name, note)
SELECT pb.id, name, note
FROM Publishers_temp AS pb, Notes AS n
WHERE n.id = pb.note_id
UNION
SELECT id, name, NULL
FROM Publishers_temp
WHERE n.id IS NULL
;

