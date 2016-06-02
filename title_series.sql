INSERT INTO Title_Series (id, title, parent, note) 
SELECT t.id, t.title, t.parent, n.note
FROM Title_Series_temp t, Notes n
WHERE t.note_id = n.id
UNION
SELECT t.id, t.title, t.parent, NULL
FROM Title_Series_temp t
WHERE t.note_id IS NULL;

ALTER TABLE Title_Series
ADD CONSTRAINT fk_parent
FOREIGN KEY(parent) REFERENCES Title_Series(id);
