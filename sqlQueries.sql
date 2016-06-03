--a)For every year, output the year and the number of publications for said year.
--then we can groupby result by year and then for each set by year we count nb of elements
--in the subset, and we output that number and the year
SELECT year, COUNT(*) FROM
	(SELECT id, YEAR(pb_date) AS year  FROM Publications) AS Res1
GROUP BY year;

--b)Output the names of the ten authors with most publications.
/**
 * (select la colomne publication_id et title_id et author_name et author_id)
 * on groupby author id les tuples tels que author.id = writes.author_id &&
 * writes.title_id = is_published_as.title_id
 * ensuite on count le nombre de publication_id pour chaque set identifié par author_id
 * on sort ensuite le resultat et on output TOP 10
 */
SELECT  a.name, COUNT(*) AS nb_publications  
FROM Authors a, authors_have_publications pb_as 
WHERE a.id = pb_as.author_id 
GROUP BY a.id
ORDER BY nb_publications DESC
LIMIT 10;

--c)What are the names of the youngest and oldest authors to publish something in 2010?
-- can we do something more elegant? here we used two queries that are almost the same
-- except for the DESC additional keyword in the second query.
	-- query for the youngest author who published in 2010
--first part: query for the oldest author who (got) published in 2010
SELECT a.name, pb_date, a.birthdate
FROM Authors a, authors_have_publications pb_as, Publications pb
WHERE YEAR(pb_date) = 2010 AND a.id = pb_as.author_id AND pb.id = pb_as.pub_id
AND a.birthdate IS NOT NULL AND a.birthdate != Date(0000-00-00)
AND Year(a.birthdate) != Year(0000-00-00) 
/*we don't want year 0000 because it's unlikely that year 0000 means known data*/
ORDER BY a.birthdate
LIMIT 1;
/*below: query for the youngest author who published in 2010*/
SELECT a.name, pb_date, a.birthdate
FROM Authors a, authors_have_publications pb_as, Publications pb
WHERE YEAR(pb_date) = 2010 AND a.id = pb_as.author_id AND pb.id = pb_as.pub_id
AND a.birthdate IS NOT NULL AND a.birthdate != Date(0000-00-00)
AND Year(a.birthdate) != Year(0000-00-00)
ORDER BY a.birthdate DESC
LIMIT 1;

-- d)How many comics (graphic titles) have publications with less than 50 pages, less than 100 pages, and
--more (or equal) than 100 pages?

--si on créé Title_Publications:
SELECT `less than 50 pages`, `less than 100 pages`, `more than 100 pages` FROM (
	(SELECT COUNT(*) AS `less than 50 pages`
	FROM Titles t, Titles_published_as_Publications t_p, Publications p
	WHERE t.id = t_p.title_id AND t_p.pub_id = p.id AND
	t.title_graphic = 1 AND nb_pages < 50) AS res1
	,
	(SELECT COUNT(*) AS `less than 100 pages`
	FROM Titles t, Titles_published_as_Publications t_p, Publications p
	WHERE t.id = t_p.title_id AND t_p.pub_id = p.id AND
	t.title_graphic AND p.nb_pages < 100) AS res2
	,
	(SELECT COUNT(*) AS `more than 100 pages`
	FROM Titles t, Titles_published_as_Publications t_p, Publications p
	WHERE t.id = t_p.title_id AND t_p.pub_id = p.id AND
	t.title_graphic = 1 AND nb_pages >= 100) AS res3
);

/*e) For every publisher, calculate the average price of its published novels (the ones that have 
a dollar price).
*/

SELECT pbsher.name AS "Publisher name", pbsher.id AS "Publisher id", 
	AVG(pb.price) AS "Average Publisher publication price"
FROM Publishers pbsher, Publications pb
WHERE pbsher.id = pb.publisher_id AND pb.price IS NOT NULL
GROUP BY pbsher.id;

/*
 * f) What is the name of the author with the highest number of titles that are tagged as 
 * “science fiction”?
 */
--first select all tuples of type (author, title) where title is tagged as science fiction
--and group them by the author name
SELECT * FROM (
	SELECT a.name, COUNT(*) AS "number of science fiction titles written" 
	FROM Authors a, authors_have_publications ap,
		Titles_published_as_Publications tp, title_has_tag tt, Tags
	WHERE a.id = ap.author_id AND ap.pub_id = tp.pub_id AND 
		tp.title_id = tt.title_id AND tt.tag_id = Tags.id AND 
		Tags.name = 'science fiction'
	GROUP BY a.name
) AS r1 
ORDER BY `number of science fiction titles written` DESC 
LIMIT 1;


/*
 *g) List the three most popular titles (i.e., the ones with the most awards and reviews).
 */
-- we'll say that the degree of popularity of a title is equal to the sum of 
-- the number of reviews and the number of awards for this title

SELECT r1.title /*if testing the query use * instead of tr.title_id to see the popularity column*/
FROM (
	SELECT t.title AS title, (tit_rev.nb_reviews + tit_awrds.nb_awards) AS popularity
	FROM Titles t,
	(SELECT title_id, COUNT(*) AS nb_reviews
	FROM title_is_reviewed_by 
	GROUP BY title_id) AS tit_rev,
	(SELECT title_id, COUNT(*) AS nb_awards
	FROM title_wins_award
	GROUP BY title_id) AS tit_awrds
	WHERE tit_rev.title_id = tit_awrds.title_id AND
		t.id = tit_awrds.title_id 
	ORDER BY popularity DESC
	LIMIT 3
) AS r1;
