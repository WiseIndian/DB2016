--a)For every year, output the year and the number of publications for said year.
--then we can groupby result by year and then for each set by year we count nb of elements
--in the subset, and we output that number and the year
SELECT year, COUNT(*) FROM
	(SELECT id, YEAR(pb_date) AS year  FROM Publications)
GROUP BY year;

--b)Output the names of the ten authors with most publications.
/**
 * (select la colomne publication_id et title_id et author_name et author_id)
 * on groupby author id les tuples tels que author.id = writes.author_id &&
 * writes.title_id = is_published_as.title_id
 * ensuite on count le nombre de publication_id pour chaque set identifié par author_id
 * on sort ensuite le resultat et on output TOP 10
 */
SELECT TOP 10 * FROM (
	SELECT  a.name, COUNT(*) AS nb_publications  
	FROM Authors a, authors_have_publications pb_as 
	WHERE a.id = pb_as.author_id 
	GROUP BY a.id
	ORDER BY nb_publications
);

--c)What are the names of the youngest and oldest authors to publish something in 2010?
-- can we do something more elegant? here we used two queries that are almost the same
-- except for the DESC additional keyword in the second query.
	-- query for the youngest author who published in 2010
SELECT TOP 1 a.name
FROM Authors a, authors_have_publications pb_as, Publications pb
WHERE YEAR(pb_date) = 2010 AND a.id = pb_as.author_id AND pb.id = pb_as.pub_id
ORDER BY a.birthdate
UNION
--query for the oldest author who published in 2010
SELECT TOP 1 a.name
FROM Authors a, authors_have_publications pb_as, Publications pb
WHERE YEAR(pb_date) = 2010 AND a.id = pb_as.author_id AND pb.id = pb_as.pub_id
ORDER BY a.birthdate DESC
;

-- d)How many comics (graphic titles) have publications with less than 50 pages, less than 100 pages, and
--more (or equal) than 100 pages?

-- si on créé pas Title_Publications et que Publications suit un format proche du csv
SELECT * FROM (
	SELECT COUNT(*) AS "less than 50 pages"
	FROM Titles t, Publications p 
	WHERE t.title = p.title AND t.title_graphic = 1 AND nb_pages < 50
	,
	SELECT COUNT(*) AS "less than 100 pages"
	FROM Titles t, Publications p 
	WHERE t.title = p.title AND t.title_graphic = 1 AND nb_pages < 100
	, 
	SELECT COUNT(*) AS "more than 100 pages"
	FROM Titles t, Publications p 
	WHERE t.title = p.title AND t.title_graphic = 1 AND nb_pages >= 50
);
--si on créé Title_Publications:
SELECT * FROM (
	SELECT COUNT(*) AS "less than 50 pages"
	FROM Titles t, Title_Publications t_p
	WHERE t.id = t_p.title_id AND t.title_graphic = 1 AND nb_pages < 50
	,
	SELECT COUNT(*) AS "less than 100 pages"
	FROM Titles t, Title_Publications t_p
	WHERE t.id = t_p.title_id AND t.title_graphic = 1 AND nb_pages < 100
	,
	SELECT COUNT(*) AS "more than 100 pages"
	FROM Titles t, Title_Publications t_p
	WHERE t.id = t_p.title_id AND t.title_graphic = 1 AND nb_pages >= 100
);







/*e) For every publisher, calculate the average price of its published novels (the ones that have 
a dollar price).
*/

SELECT pbsher.name AS "Publisher name", pbsher.id AS "Publisher id", 
	AVG(pb.price) AS "Average Publisher publication price"
FROM Publishers pbsher, Publications pb
WHERE pbsher.id = pb.publisher_id
GROUP BY pbsher.id
;

/*
 * f) What is the name of the author with the highest number of titles that are tagged as 
 * “science fiction”?
 */
--first select all tuples of type (author, title) where title is tagged as science fiction
--and group them by the author name
SELECT TOP 1 * FROM (
	SELECT a.name, COUNT(*) AS "number of science fiction titles written" 
	FROM Authors a, authors_have_publications ap, Title_Publications tp, title_has_tag tt, Tags
	WHERE a.id = ap.author_id AND ap.pub_id = tp.pub_id AND 
		tp.title_id = tt.title_id AND tt.tag_id = Tags.id AND 
		Tags.name = 'science fiction'
	GROUP BY a.name
)
ORDER BY "number of science fiction titles written" DESC ;





/*
 *g) List the three most popular titles (i.e., the ones with the most awards and reviews).
 */
