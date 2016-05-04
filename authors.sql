INSERT INTO
Authors (id,  name,  legal_name ,  last_name,
  pseudo,  birthplace,  birthdate,  deathdate,  email, 
  img_link,  language_id,  note)
SELECT a.id, a.name, a.legal_name, a.last_name, a.pseudo, a.birthplace,
a.birthdate, a.deathdate, a.email, a.img_link, a.language_id, NULL
FROM Authors_temp a
WHERE a.note_id = NULL
UNION
SELECT a.id, a.name, a.legal_name, a.last_name, a.pseudo, a.birthplace,
	a.birthdate, a.deathdate, a.email, a.img_link, a.language_id, n.note
FROM Authors_temp a, Notes n
WHERE a.note_id = n.id;
