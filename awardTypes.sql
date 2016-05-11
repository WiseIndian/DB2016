INSERT INTO Award_Types(id, code, name, note, awarded_by, awarded_for, 
			short_name, is_poll, non_genre)
SELECT a_t.id, code, name, n.note, awarded_by, awarded_for, short_name,
        is_poll, non_genre
FROM Award_Types_temp a_t, Notes n
WHERE a_t.note_id = n.id
UNION
SELECT a_t.id, code, name, NULL, awarded_by, awarded_for, short_name,
        is_poll, non_genre
FROM Award_Types_temp a_t
WHERE a_t.note_id = NULL
;

