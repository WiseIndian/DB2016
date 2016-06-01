INSERT INTO title_is_translated_in(
	title_id, trans_title_id, language_id, translator) 
SELECT parent, title_id, language_id, title_translator
FROM Titles_temp
WHERE parent IS NOT NULL AND title_id IS NOT NULL AND language_id IS NOT NULL
AND title_translator IS NOT NULL;

