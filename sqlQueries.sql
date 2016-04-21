--a)For every year, output the year and the number of publications for said year.
--then we can groupby result by year and then for each set by year we count nb of elements
--in the subset, and we output that number and the year
--TODO: change date into another name (it's a reserved sql keyword)
SELECT year, COUNT(*) FROM
	(SELECT id, YEAR(date) AS year  FROM Publications)
GROUP BY year 

--b)Output the names of the ten authors with most publications.
/**
 * (select la colomne publication_id et title_id et author_name et author_id)
 * on groupby author id les tuples tels que author.id = writes.author_id &&
 * writes.title_id = is_published_as.title_id
 * ensuite on count le nombre de publication_id pour chaque set identifié par author_id
 * on sort ensuite le resultat et on output TOP 10
 */
 --TODO: verfier que Publication_authors est bien le bon nom
 --TODO: verifier que author_id est bien le bon nom pour le champs de Publication_authors
SELECT TOP 10 * FROM (
	SELECT  a.name, COUNT(*) AS nb_publications  
	FROM Authors a, Publication_authors pb_as 
	WHERE a.id = pb_as.author_id 
	GROUP BY a.id
	ORDER BY nb_publications
)

--c)What are the names of the youngest and oldest authors to publish something in 2010?
-- can we do something more elegant? here we used two queries that are almost the same
-- except for the DESC additional keyword in the second query.
	-- query for the youngest author who published in 2010
	SELECT TOP 1 a.name
	FROM Authors a, Publication_authors pb_as, Publications pb
	--TODO author_id good name? Publication_authors good name? publication_id good name?
	--TODO find another name for date attribute of a publication here we called it date
	-- but it's actually a reserved sql keyword :o
	WHERE YEAR(pb.date) = 2010 AND a.id = pb_as.author_id AND pb.id = pb_as.publication_id
	ORDER BY a.birthdate
UNION
	--query for the oldest author who published in 2010
	SELECT TOP 1 a.name
	FROM Authors a, Publication_authors pb_as, Publications pb
	--TODO author_id good name? Publication_authors good name? publication_id good name?
	--TODO find another name for date attribute of a publication here we called it date
	-- but it's actually a reserved sql keyword :o
	WHERE YEAR(pb.date) = 2010 AND a.id = pb_as.author_id AND pb.id = pb_as.publication_id
	ORDER BY a.birthdate DESC

/* select all publications of graphic titles, select all publications with less than 50 pages
*/

--How many comics (graphic titles) have publications with less than 50 pages, less than 100 pages, and
--more (or equal) than 100 pages?

/*e) For every publisher, calculate the average price of its published novels (the ones that have a dollar
price).
f) What is the name of the author with the highest number of titles that are tagged as “science fiction”?
g) List the three most popular titles (i.e., the ones with the most awards and reviews).
*/
