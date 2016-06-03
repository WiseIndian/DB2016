/* Returns the title_id of the most popular title (title with most publications) : */
QUERY1 =
SELECT title_id FROM (
	SELECT title_id, COUNT(*) AS nbPublications
	FROM Title_Publications
	GROUP BY title_id
	ORDER BY nbPublications DESC
	LIMIT 1
)

/* Returns the table containing all the Publications (pub_id) of the most popupar title : */
QUERY2 = 
SELECT pub_id AS pid
FROM Title_Publications
WHERE title_id = QUERY1

/* Returns the average price of these publications in Dollar/Pound : */
QUERY3 =
SELECT Avg(price) 
FROM Publications P, QUERY2
WHERE pid = P.id  AND  currency = 'DOLLAR'/*'POUND'*/