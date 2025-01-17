s"""SELECT year, COUNT(*) FROM""" +
"""	(SELECT id, YEAR(pb_date) AS year  FROM Publications) AS Res1""" +
"""GROUP BY year;"""



s"""SELECT  a.name, COUNT(*) AS nb_publications  """ +
"""FROM Authors a, authors_have_publications pb_as """ +
"""WHERE a.id = pb_as.author_id """ +
"""GROUP BY a.id""" +
"""ORDER BY nb_publications DESC""" +
"""LIMIT 10;"""



s"""SELECT a.name, pb_date, a.birthdate""" +
"""FROM Authors a, authors_have_publications pb_as, Publications pb""" +
"""WHERE YEAR(pb_date) = 2010 AND a.id = pb_as.author_id AND pb.id = pb_as.pub_id""" +
"""AND a.birthdate IS NOT NULL AND a.birthdate != Date(0000-00-00)""" +
"""AND Year(a.birthdate) != Year(0000-00-00) """ +
"""ORDER BY a.birthdate""" +
"""LIMIT 1;"""



s"""SELECT a.name, pb_date, a.birthdate""" +
"""FROM Authors a, authors_have_publications pb_as, Publications pb""" +
"""WHERE YEAR(pb_date) = 2010 AND a.id = pb_as.author_id AND pb.id = pb_as.pub_id""" +
"""AND a.birthdate IS NOT NULL AND a.birthdate != Date(0000-00-00)""" +
"""AND Year(a.birthdate) != Year(0000-00-00)""" +
"""ORDER BY a.birthdate DESC""" +
"""LIMIT 1;"""



s"""SELECT `less than 50 pages`, `less than 100 pages`, `more than 100 pages` FROM (""" +
"""	(SELECT COUNT(*) AS `less than 50 pages`""" +
"""	FROM Titles t, Titles_published_as_Publications t_p, Publications p""" +
"""	WHERE t.id = t_p.title_id AND t_p.pub_id = p.id AND""" +
"""	t.title_graphic = 1 AND nb_pages < 50) AS res1""" +
"""	,""" +
"""	(SELECT COUNT(*) AS `less than 100 pages`""" +
"""	FROM Titles t, Titles_published_as_Publications t_p, Publications p""" +
"""	WHERE t.id = t_p.title_id AND t_p.pub_id = p.id AND""" +
"""	t.title_graphic AND p.nb_pages < 100) AS res2""" +
"""	,""" +
"""	(SELECT COUNT(*) AS `more than 100 pages`""" +
"""	FROM Titles t, Titles_published_as_Publications t_p, Publications p""" +
"""	WHERE t.id = t_p.title_id AND t_p.pub_id = p.id AND""" +
"""	t.title_graphic = 1 AND nb_pages >= 100) AS res3""" +
""");"""



s"""SELECT pbsher.name AS "Publisher name", pbsher.id AS "Publisher id", """ +
"""	AVG(pb.price) AS "Average Publisher publication price"""" +
"""FROM Publishers pbsher, Publications pb""" +
"""WHERE pbsher.id = pb.publisher_id AND pb.price IS NOT NULL""" +
"""GROUP BY pbsher.id;"""



s"""SELECT * FROM (""" +
"""	SELECT a.name, COUNT(*) AS "number of science fiction titles written" """ +
"""	FROM Authors a, authors_have_publications ap,""" +
"""		Titles_published_as_Publications tp, title_has_tag tt, Tags""" +
"""	WHERE a.id = ap.author_id AND ap.pub_id = tp.pub_id AND """ +
"""		tp.title_id = tt.title_id AND tt.tag_id = Tags.id AND """ +
"""		Tags.name = 'science fiction'""" +
"""	GROUP BY a.name""" +
""") AS r1 """ +
"""ORDER BY `number of science fiction titles written` DESC """ +
"""LIMIT 1;"""



s"""SELECT r1.title /*if testing the query use * instead of tr.title_id to see the popularity column*/""" +
"""FROM (""" +
"""	SELECT t.title AS title, (tit_rev.nb_reviews + tit_awrds.nb_awards) AS popularity""" +
"""	FROM Titles t,""" +
"""	(SELECT title_id, COUNT(*) AS nb_reviews""" +
"""	FROM title_is_reviewed_by """ +
"""	GROUP BY title_id) AS tit_rev,""" +
"""	(SELECT title_id, COUNT(*) AS nb_awards""" +
"""	FROM title_wins_award""" +
"""	GROUP BY title_id) AS tit_awrds""" +
"""	WHERE tit_rev.title_id = tit_awrds.title_id AND""" +
"""		t.id = tit_awrds.title_id """ +
"""	ORDER BY popularity DESC""" +
"""	LIMIT 3""" +
""") AS r1;"""



s"""SELECT Avg(price) """ +
"""FROM Publications P, """ +
"""(SELECT pub_id AS pid""" +
"""FROM Titles_published_as_Publications""" +
"""WHERE title_id = (SELECT title_id FROM (""" +
"""                        SELECT title_id, COUNT(*) AS nbPublications""" +
"""                        FROM Titles_published_as_Publications""" +
"""                        GROUP BY title_id""" +
"""                        ORDER BY nbPublications DESC""" +
"""                        LIMIT 1""" +
"""                  ) as r1 ) """ +
""") as r2""" +
"""WHERE pid = P.id  AND  currency = 'DOLLAR'/*'POUND'*/""" +
s"""SELECT t_s.title, """ +
"""	SUM(tit_awrds.nb_awards) AS popularity""" +
"""FROM Titles t, Title_Series t_s,""" +
"""(SELECT title_id, COUNT(*) AS nb_awards""" +
"""FROM title_wins_award""" +
"""GROUP BY title_id) AS tit_awrds""" +
"""WHERE t.series_id = t_s.id AND t.id = tit_awrds.title_id""" +
"""GROUP BY t_s.id""" +
"""ORDER BY popularity DESC""" +
"""LIMIT 10;"""



s"""SELECT a.name,  COUNT(*) AS nb_awards_when_dead""" +
"""FROM Awards aw, title_wins_award t_w_a, """ +
"""	Titles_published_as_Publications t_p, authors_have_publications a_p,""" +
"""	Authors a""" +
"""WHERE aw.aw_date IS NOT NULL AND a.deathdate IS NOT NULL AND""" +
(
"""	DATEDIFF(aw.aw_date, a.deathdate) > 0  OR""" +
"""	YEAR(aw.aw_date) > YEAR(a.deathdate) OR """ +
"""	(""" +
"""		YEAR(aw.aw_date) >= YEAR(a.deathdate) AND""" +
"""		MONTH(aw.aw_date) > MONTH(a.deathdate) AND """ +
"""		MONTH(aw.aw_date) != 0 AND MONTH(a.deathdate) != 0""" +
"""	)""" +
""") AND""" +
"""aw.id = t_w_a.award_id AND t_w_a.title_id = t_p.title_id AND """ +
"""t_p.title_id AND t_p.pub_id = a_p.pub_id AND""" +
"""a_p.pub_id AND a_p.author_id = a.id""" +
"""GROUP BY a.id """ +
"""ORDER BY nb_awards_when_dead DESC""" +
"""LIMIT 10""" +
;
s"""SELECT pbshr.name as pbshr_name, p.pb_date,""" +
"""	 COUNT(*) AS nb_publications_by_publisher""" +
"""FROM Publications p, Publishers pbshr""" +
"""WHERE p.publisher_id = pbshr.id AND YEAR(p.pb_date) = 1989""" +
"""GROUP BY pbshr.id""" +
"""ORDER BY nb_publications_by_publisher DESC""" +
"""LIMIT 3;"""



s"""SELECT t.title, COUNT(*) AS nb_of_awards""" +
"""FROM Titles t, authors_have_publications a_p, Titles_published_as_Publications t_p, """ +
"""	title_wins_award t_w_a """ +
"""WHERE """ +
"""	a_p.author_id =""" +
"""	(SELECT a.id""" +
"""	FROM Authors a WHERE a.name = 'Isaac Asimov'""" +
"""	LIMIT 1) AND  a_p.pub_id = t_p.pub_id AND """ +
"""	t.id = t_p.title_id AND t_p.title_id = t_w_a.title_id """ +
"""GROUP BY t_w_a.title_id""" +
"""ORDER BY nb_of_awards DESC""" +
"""LIMIT 1;"""



s"""SELECT """ +
"""FROM """ +
"""Languages l, """ +
(
"""	SELECT t.id, t_t.language_id  """ +
"""	FROM Titles t, title_is_translated_in t_t""" +
"""	WHERE """ +
)
"""GROUP BY t_t.language_id)""" +
s"""SELECT years2.y, AVG(result1.authors_per_publisher)""" +
"""FROM""" +
"""(SELECT DISTINCT YEAR(pb_date) AS y FROM Publications ORDER BY y) AS years2,""" +
(
"""	SELECT pbshr.name, COUNT(*) as authors_per_publisher, years.y as y""" +
"""	FROM """ +
"""	(SELECT DISTINCT YEAR(pb_date) AS y FROM Publications ORDER BY y) AS years,""" +
"""	Publishers pbshr, Publications p, authors_have_publications a_p, Authors a""" +
"""	WHERE pbshr.id = p.publisher_id AND p.id = a_p.pub_id AND a_p.author_id = a.id""" +
"""	AND YEAR(p.pb_date) = years.y""" +
"""	GROUP BY pbshr.id""" +
""") as result1""" +
"""WHERE years2.y = result1.y""" +
"""GROUP BY years2.y;"""



s"""SELECT a.id, a.name, COUNT(a_p.pub_id) AS nb_published_anthologies""" +
"""FROM Authors a, authors_have_publications a_p,""" +
"""Titles_published_as_Publications t_p, Titles t""" +
"""WHERE a.deathdate IS NULL AND a.birthdate IS NOT NULL AND """ +
"""DATEDIFF(CURDATE(), a.birthdate) / 365 < 100  AND""" +
"""a.id = a_p.author_id AND a_p.pub_id IS NOT NULL AND""" +
"""a_p.pub_id = t_p.pub_id AND t_p.title_id = t.id AND """ +
"""t.title_type = 'ANTHOLOGY'""" +
"""GROUP BY a.id""" +
"""HAVING nb_published_anthologies > 0""" +
"""ORDER BY nb_published_anthologies;"""



s"""SELECT AVG(nb_publications_for_this_serie) AS "average number of publications per serie"""" +
"""FROM (""" +
"""	SELECT p.title, COUNT(p.id) AS nb_publications_for_this_serie""" +
"""	FROM Publication_Series ps, Publications p""" +
"""	WHERE p.publication_series_id = ps.id AND """ +
"""	ps.name IS NOT NULL AND p.title IS NOT NULL""" +
"""	GROUP BY ps.id""" +
""") AS r1;"""



s"""SELECT a.name, COUNT(t_w_b.review_title_id) AS "number of reviews written"""" +
"""FROM title_is_reviewed_by t_w_b, Titles_published_as_Publications t_p,""" +
"""authors_have_publications a_p, Authors a""" +
"""WHERE t_w_b.review_title_id = t_p.title_id AND t_p.pub_id AND""" +
"""t_p.pub_id = a_p.pub_id AND a_p.author_id = a.id  """ +
"""GROUP BY a.id""" +
"""ORDER BY `number of reviews written` DESC """ +
"""LIMIT 1;"""



s"""SELECT a.name, a.id, AVG(p.nb_pages / p.price) AS "pages per dollar ratio"""" +
"""FROM Publications p, authors_have_publications a_p, Authors a""" +
"""WHERE p.id = a_p.pub_id AND a_p.author_id = a.id AND p.currency = 'DOLLAR'""" +
"""GROUP BY a.id""" +
"""ORDER BY `pages per dollar ratio` DESC""" +
"""LIMIT 10;"""



s"""SELECT pid, SUM(inner_sum) as tot_refs""" +
"""FROM (""" +
"""	(SELECT p.id AS pid, COUNT(*) as inner_sum""" +
"""	FROM Publications p, authors_have_publications a_p, authors_referenced_by a_r_b""" +
"""	WHERE p.id = a_p.pub_id AND  a_p.author_id = a_r_b.author_id""" +
"""	GROUP BY p.id) """ +
"""	UNION""" +
"""	(SELECT p.id AS pid, COUNT(*) as inner_sum""" +
"""	FROM Publications p, Titles_published_as_Publications t_p, title_wins_award t_w_a,""" +
"""		Awards aw, award_categories_referenced_by a_c_r""" +
"""	WHERE p.id = t_p.pub_id AND t_p.title_id = t_w_a.title_id AND """ +
"""		t_w_a.award_id = aw.id AND aw.category_id = a_c_r.award_category_id""" +
"""	GROUP BY p.id)""" +
"""	UNION""" +
"""	(SELECT p.id AS pid, COUNT(*) as inner_sum""" +
"""	FROM Publications p, Titles_published_as_Publications t_p, title_wins_award t_w_a,""" +
"""		Awards aw, award_types_referenced_by a_t_r""" +
"""	WHERE p.id = t_p.pub_id AND t_p.title_id = t_w_a.title_id AND""" +
"""		t_w_a.award_id = aw.id AND aw.type_id = a_t_r.award_type_id""" +
"""	GROUP BY p.id)""" +
"""	UNION""" +
"""	(SELECT p.id AS pid, COUNT(*) as inner_sum""" +
"""	FROM Publications p, Publication_Series p_s, publication_series_referenced_by p_s_r""" +
"""	WHERE p.publication_series_id = p_s.id AND p_s.id = p_s_r.publication_series_id""" +
"""	GROUP BY p.id)""" +
"""	UNION""" +
"""	(SELECT p.id AS pid, COUNT(*) as inner_sum""" +
"""	FROM Publications p, publishers_referenced_by p_r""" +
"""	WHERE p.publisher_id = p_r.publisher_id""" +
"""	GROUP BY p.id)""" +
"""	UNION""" +
"""	(SELECT p.id AS pid, COUNT(*) as inner_sum""" +
"""	FROM Publications p, Titles_published_as_Publications t_p, Titles t, """ +
"""		title_series_referenced_by t_s_r""" +
"""	WHERE p.id = t_p.pub_id AND t_p.title_id = t.id AND """ +
"""		t.series_id = t_s_r.title_series_id""" +
"""	GROUP BY p.id)""" +
"""	UNION""" +
"""	(SELECT p.id AS pid, COUNT(*) as inner_sum""" +
"""	FROM Publications p, Titles_published_as_Publications t_p, titles_referenced_by t_r""" +
"""	WHERE p.id = t_p.pub_id AND t_p.title_id = t_r.title_id""" +
"""	GROUP BY p.id)""" +
""") AS r,""" +
"""Titles_published_as_Publications outter_t_p, title_wins_award outter_t_w_a, """ +
"""	Awards outter_aw, Award_Types outter_a_t""" +
"""WHERE r.pid = outter_t_p.pub_id AND outter_t_p.title_id = outter_t_w_a.title_id AND""" +
"""	outter_t_w_a.award_id = outter_aw.id AND """ +
"""	outter_aw.type_id = (SELECT id FROM Award_Types WHERE name = 'Nebula award')""" +
"""GROUP BY pid """ +
"""ORDER BY tot_refs DESC""" +
""" LIMIT 10;"""




