---------DELIV 2 QUERRIES---------------

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



-----------DELIV 3 QUERRIES-------------
--a) Compute the average price per currency of the publications of the most popular title (i.e, the title with
--most publications overall).


/* Returns the average price of these publications in Dollar/Pound : */
SELECT Avg(price) 
FROM Publications P, 
/* Query as from input Returns the table containing all the Publications 
 * (pub_id) of the most popupar title : */
(SELECT pub_id AS pid
FROM Titles_published_as_Publications
WHERE title_id = (SELECT title_id FROM (
                        SELECT title_id, COUNT(*) AS nbPublications
                        FROM Titles_published_as_Publications
                        GROUP BY title_id
                        ORDER BY nbPublications DESC
                        LIMIT 1
                  ) as r1 ) 
) as r2
WHERE pid = P.id  AND  currency = 'DOLLAR'/*'POUND'*/
;



--b) Output the names of the top ten title series with most awards.
SELECT t_s.title, 
	SUM(tit_awrds.nb_awards) AS popularity
FROM Titles t, Title_Series t_s,
(SELECT title_id, COUNT(*) AS nb_awards
FROM title_wins_award
GROUP BY title_id) AS tit_awrds
WHERE t.series_id = t_s.id AND t.id = tit_awrds.title_id
GROUP BY t_s.id
ORDER BY popularity DESC
LIMIT 10;

--c) Output the name of the author who has received the most awards after his/her death.
SELECT a.name,  COUNT(*) AS nb_awards_when_dead
FROM Awards aw, title_wins_award t_w_a, 
	Titles_published_as_Publications t_p, authors_have_publications a_p,
	Authors a
WHERE aw.aw_date IS NOT NULL AND a.deathdate IS NOT NULL AND
(
	DATEDIFF(aw.aw_date, a.deathdate) > 0  OR
	YEAR(aw.aw_date) > YEAR(a.deathdate) OR 
	(
		YEAR(aw.aw_date) >= YEAR(a.deathdate) AND
		MONTH(aw.aw_date) > MONTH(a.deathdate) AND 
		MONTH(aw.aw_date) != 0 AND MONTH(a.deathdate) != 0
	)
) AND
aw.id = t_w_a.award_id AND t_w_a.title_id = t_p.title_id AND 
t_p.title_id AND t_p.pub_id = a_p.pub_id AND
a_p.pub_id AND a_p.author_id = a.id
GROUP BY a.id 
ORDER BY nb_awards_when_dead DESC
LIMIT 10
;
		

--d) For a given year, output the three publishers that published the most publications.
--we understood that by for a given year we could put a 
--value given by the interface. We put 1989 for the moment.  
--TODO with interface input a value to the YEAR(p.pb_date) = ... 
SELECT pbshr.name as pbshr_name, p.pb_date,
	 COUNT(*) AS nb_publications_by_publisher
FROM Publications p, Publishers pbshr
WHERE p.publisher_id = pbshr.id AND YEAR(p.pb_date) = 1989 OR 1
GROUP BY pbshr.id
ORDER BY nb_publications_by_publisher DESC
LIMIT 3;

--e) Given an author, compute his/her most reviewed title(s).
--TODO link with interface in such a way that the name will replace current 'Isaac Asimov'

SELECT t.title, COUNT(*) AS "nb of reviews"
FROM Titles t, Titles_published_as_Publications t_p, authors_have_publications a_p,
  title_is_reviewed_by t_r_b
WHERE a_p.author_id =
  (SELECT a.id
  FROM Authors a WHERE a.name = ?
  LIMIT 1) AND
a_p.pub_id = t_p.pub_id AND t.id = t_p.title_id AND 
t_p.title_id = t_r_b.title_id
GROUP BY a_p.pub_id
ORDER BY `nb of reviews` DESC
LIMIT 1;

--m) For every language, list the three authors with the most translated titles of “novel” type.
SET @currcount = NULL, @currvalue = NULL;
SELECT lname AS "language name",
  tname AS "title", aname,
  nb_translations AS "number of translation of this title originally written in this language"
FROM
(
  SELECT
    lid, tid, nb_translations, lname, tname, a.name AS aname,
    @currcount := IF(@currvalue = lid, @currcount + 1, 1) AS rank,
    @currvalue := lid
  FROM(
    SELECT
      l.id AS lid, t.id AS tid,
      l.name AS lname, t.title AS tname, COUNT(*) AS nb_translations
    FROM Languages l, Titles t, title_is_translated_in t_i_t
    WHERE l.id = t.language_id AND t.id = t_i_t.title_id AND
      t.title_type='NOVEL'  
    GROUP BY l.id, t.id
    ORDER BY l.id
  ) AS r1,
  Authors a, authors_have_publications a_p, 
  Titles_published_as_Publications t_p
  WHERE a.id = a_p.author_id AND
      a_p.pub_id = t_p.pub_id AND t_p.title_id = tid
) as r2
WHERE rank <= 3
GROUP BY r2.lname, r2.tname, r2.aname, r2.nb_translations
ORDER BY lid, nb_translations DESC;

  
--f) For every language, find the top three title types with most translations.
SET @currcount = NULL, @currvalue = NULL;
SELECT lname AS "language name",
  tname AS "title", 
  nb_translations AS "number of translation of this title originally written in this language"
FROM
  (
    SELECT 
      lid, tid, nb_translations, lname, tname,
      @currcount := IF(@currvalue = lid, @currcount + 1, 1) AS rank,
      @currvalue := lid
    FROM(
      SELECT
        l.id AS lid, t.id AS tid,
        l.name AS lname, t.title AS tname, COUNT(*) AS nb_translations
      FROM Languages l, Titles t, title_is_translated_in t_i_t
      WHERE l.id = t.language_id AND t.id = t_i_t.title_id 
      GROUP BY l.id, t.id
      ORDER BY l.id
    ) AS r1
  ) as r2
WHERE rank <= 3

--g) For each year, compute the average number of authors per publisher.
SELECT years2.y, AVG(result1.authors_per_publisher)
FROM
(SELECT DISTINCT YEAR(pb_date) AS y FROM Publications ORDER BY y) AS years2,
(
	SELECT pbshr.name, COUNT(*) as authors_per_publisher, years.y as y
	FROM 
	(SELECT DISTINCT YEAR(pb_date) AS y FROM Publications ORDER BY y) AS years,
	Publishers pbshr, Publications p, authors_have_publications a_p, Authors a
	WHERE pbshr.id = p.publisher_id AND p.id = a_p.pub_id AND a_p.author_id = a.id
	AND YEAR(p.pb_date) = years.y
	GROUP BY pbshr.id
) as result1
WHERE years2.y = result1.y
GROUP BY years2.y;

--h) Find the publication series with most titles that have been given awards of “World Fantasy Award”
--type.
SELECT p_s.name AS "publication series name", 
    COUNT(*) AS "number of titles of the publication serie awarded the world fantasy award"
FROM Publication_Series p_s, Publications p, Titles_published_as_Publications t_p,
     Titles t, title_wins_award t_w_a, Awards aw, Award_Types a_t
WHERE p_s.id = p.publication_series_id AND p.id = t_p.pub_id AND 
    t_p.title_id = t.id AND t.id = t_w_a.title_id AND t_w_a.award_id = aw.id AND
    aw.type_id = a_t.id AND a_t.name = 'World Fantasy Award'
GROUP BY p_s.id
ORDER BY `number of titles of the publication serie awarded the world fantasy award` DESC
LIMIT 1;
--i) For every award category, list the names of the three most awarded authors.
-- of every category

SET @currcount = NULL, @currvalue = NULL, @str = NULL;

SELECT r.aname, r.a_c_name, r.nb_awards_for_author  FROM (
  SELECT a.name AS aname, a_c.name AS a_c_name, a_c.id AS a_c_id,
       COUNT(*) AS nb_awards_for_author,
       @currcount := IF(@currvalue = a_c.id, @currcount + 1, 1) AS rank,
       @currvalue := a_c.id
  FROM Award_Categories a_c, Awards aw, title_wins_award t_w_a,
    Titles_published_as_Publications t_p, authors_have_publications a_h_p, Authors a
  WHERE a_c.id = aw.category_id AND aw.id = t_w_a.award_id AND 
    t_w_a.title_id = t_p.title_id AND t_p.pub_id = a_h_p.pub_id AND 
    a_h_p.author_id = a.id 
  GROUP BY a_c.id, a.id
  ORDER BY a_c.id, nb_awards_for_author DESC
  ) AS r
WHERE r.rank <= 3;

--j) Output the names of all living authors that have published at least one anthology from youngest to
--oldest.
--here we make the approximation that someones who's unknowingly dead (i.e. not marked as dead
-- and has been born less 100 year ago is still alive).
SELECT a.id, a.name, COUNT(a_p.pub_id) AS nb_published_anthologies
FROM Authors a, authors_have_publications a_p,
Titles_published_as_Publications t_p, Titles t
WHERE a.deathdate IS NULL AND a.birthdate IS NOT NULL AND 
DATEDIFF(CURDATE(), a.birthdate) / 365 < 100  AND
a.id = a_p.author_id AND a_p.pub_id IS NOT NULL AND
a_p.pub_id = t_p.pub_id AND t_p.title_id = t.id AND 
t.title_type = 'ANTHOLOGY'
GROUP BY a.id
HAVING nb_published_anthologies > 0
ORDER BY nb_published_anthologies;

--k) Compute the average number of publications per publication series (single result/number expected).
SELECT AVG(nb_publications_for_this_serie) AS "average number of publications per serie"
FROM (
	SELECT p.title, COUNT(p.id) AS nb_publications_for_this_serie
	FROM Publication_Series ps, Publications p
	WHERE p.publication_series_id = ps.id AND 
	ps.name IS NOT NULL AND p.title IS NOT NULL
	GROUP BY ps.id
) AS r1;

--l) Find the author who has reviewed the most titles.
SELECT a.name, COUNT(t_w_b.review_title_id) AS "number of reviews written"
FROM title_is_reviewed_by t_w_b, Titles_published_as_Publications t_p,
authors_have_publications a_p, Authors a
WHERE t_w_b.review_title_id = t_p.title_id AND t_p.pub_id AND
t_p.pub_id = a_p.pub_id AND a_p.author_id = a.id  
GROUP BY a.id
ORDER BY `number of reviews written` DESC 
LIMIT 1;

--m) For every language, list the three authors with the most translated titles of “novel” type.


--n) Order the top ten authors whose publications have the largest pages per dollar ratio (considering all
--publications of an author that have a dollar price).
SELECT a.name, a.id, AVG(p.nb_pages / p.price) AS "pages per dollar ratio"
FROM Publications p, authors_have_publications a_p, Authors a
WHERE p.id = a_p.pub_id AND a_p.author_id = a.id AND p.currency = 'DOLLAR'
GROUP BY a.id
ORDER BY `pages per dollar ratio` DESC
LIMIT 10;
--o) For publications that have been awarded the Nebula award, find the top 10 with the most extensive
--web presence (i.e, the highest number of author websites, publication websites, publisher websites,
--publication series websites, and title series websites in total)
SELECT pid, SUM(inner_sum) as tot_refs
FROM (
	(SELECT p.id AS pid, COUNT(*) as inner_sum
	FROM Publications p, authors_have_publications a_p, authors_referenced_by a_r_b
	WHERE p.id = a_p.pub_id AND  a_p.author_id = a_r_b.author_id
	GROUP BY p.id) 
	UNION
	(SELECT p.id AS pid, COUNT(*) as inner_sum
	FROM Publications p, Titles_published_as_Publications t_p, title_wins_award t_w_a,
		Awards aw, award_categories_referenced_by a_c_r
	WHERE p.id = t_p.pub_id AND t_p.title_id = t_w_a.title_id AND 
		t_w_a.award_id = aw.id AND aw.category_id = a_c_r.award_category_id
	GROUP BY p.id)
	UNION
	(SELECT p.id AS pid, COUNT(*) as inner_sum
	FROM Publications p, Titles_published_as_Publications t_p, title_wins_award t_w_a,
		Awards aw, award_types_referenced_by a_t_r
	WHERE p.id = t_p.pub_id AND t_p.title_id = t_w_a.title_id AND
		t_w_a.award_id = aw.id AND aw.type_id = a_t_r.award_type_id
	GROUP BY p.id)
	UNION
	(SELECT p.id AS pid, COUNT(*) as inner_sum
	FROM Publications p, Publication_Series p_s, publication_series_referenced_by p_s_r
	WHERE p.publication_series_id = p_s.id AND p_s.id = p_s_r.publication_series_id
	GROUP BY p.id)
	UNION
	(SELECT p.id AS pid, COUNT(*) as inner_sum
	FROM Publications p, publishers_referenced_by p_r
	WHERE p.publisher_id = p_r.publisher_id
	GROUP BY p.id)
	UNION
	(SELECT p.id AS pid, COUNT(*) as inner_sum
	FROM Publications p, Titles_published_as_Publications t_p, Titles t, 
		title_series_referenced_by t_s_r
	WHERE p.id = t_p.pub_id AND t_p.title_id = t.id AND 
		t.series_id = t_s_r.title_series_id
	GROUP BY p.id)
	UNION
	(SELECT p.id AS pid, COUNT(*) as inner_sum
	FROM Publications p, Titles_published_as_Publications t_p, titles_referenced_by t_r
	WHERE p.id = t_p.pub_id AND t_p.title_id = t_r.title_id
	GROUP BY p.id)
) AS r,
Titles_published_as_Publications outter_t_p, title_wins_award outter_t_w_a, 
	Awards outter_aw, Award_Types outter_a_t
WHERE r.pid = outter_t_p.pub_id AND outter_t_p.title_id = outter_t_w_a.title_id AND
	outter_t_w_a.award_id = outter_aw.id AND 
	outter_aw.type_id = (SELECT id FROM Award_Types WHERE name = 'Nebula award')
GROUP BY pid 
ORDER BY tot_refs DESC
 LIMIT 10;

