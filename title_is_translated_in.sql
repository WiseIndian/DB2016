INSERT INTO title_is_translated_in(
	title_id, trans_title_id, language_id, translator) 
SELECT t1.parent, t1.id, t1.language_id, t1.title_translator
FROM Titles_temp AS t1, Titles AS t2, Titles AS t3 
WHERE t1.parent IS NOT NULL AND t1.id IS NOT NULL AND t1.language_id IS NOT NULL
AND t1.parent = t2.id AND t1.id = t3.id; 
/**
 * since we use Titles_temp to get translator field, and language_id field for title_is_translated_in
 * we're not sure that since Titles table was added after Titles_temp we're going to have 
 * parents id coming from Titles_temp that will always exist exist in Title as an id.
 * Same for t1.id. Thus we add two more checks in the last two AND.
 */
