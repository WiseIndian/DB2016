INSERT INTO Titles(id, title, synopsis, note,
		 story_len, title_type, parent, language_id, title_graphic) 
SELECT t.id, t.title, syn.note, n.note, t.story_len, t.title_type, t.parent,
        t.language_id, t.title_graphic
FROM Titles_temp t, Notes syn, Notes n
WHERE t.note_id = n.id AND t.synopsis_id = syn.id
UNION
SELECT t.id, t.title, NULL, n.note, t.story_len, t.title_type, t.parent,
        t.language_id, t.title_graphic
FROM Titles_temp t, Notes n
WHERE t.synopsis_id IS NULL AND t.note_id = n.id
UNION
SELECT t.id, t.title, syn.note, NULL, t.story_len, t.title_type, t.parent,
        t.language_id, t.title_graphic
FROM Titles_temp t, Notes syn
WHERE t.note_id IS NULL AND t.synopsis_id = syn.id
UNION
SELECT t.id, t.title, NULL, NULL, t.story_len, t.title_type, t.parent,
t.language_id, t.title_graphic
FROM Titles_temp t
WHERE t.note_id IS NULL AND t.synopsis_id IS NULL;
