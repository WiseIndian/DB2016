--then we can groupby result by year and then for each set by year we count nb of elements
--in the subset, and we output that number and the year
SELECT year, COUNT(id) FROM
	(SELECT id, YEAR(date) AS year  FROM Publication)
GROUP BY year 

/**
 * (select la colomne publication_id et title_id et author_name et author_id)
 * on groupby author id les tuples tels que author.id = writes.author_id &&
 * writes.title_id = is_published_as.title_id
 * ensuite on count le nombre de publication_id pour chaque set identifié par author_id
 * on sort ensuite le resultat et on output TOP 10
 */

SELECT TOP 10 * FROM (
	SELECT  author_name, COUNT(*) AS nb_publications  
	FROM Author a, Writes w, Is_published_as pb_as 
		WHERE a.id = w.author_id AND w.title_id = pb_as.title_id
	GROUP BY a.id
	ORDER BY nb_publications
)

	-- query for the youngest author who published in 2010
	SELECT TOP 1 a.name
	FROM Author a, Writes w, Is_published_as pb_as, Publication pb
	WHERE YEAR(pb.date) = 2010 AND a.id = w.author_id AND w.title_id = pb_as.title_id
		 AND  pb.id = pb_as.publication_id
	ORDER BY a.birthdate
UNION
	--query oldest author who published in 2010
	SELECT TOP 1 * a.name
	FROM Author a, Writes w, Is_published_as pb_as, Publication pb
	WHERE YEAR(pb.date) = 2010 AND a.id = w.author_id AND w.title_id = pb_as.title_id
		 AND  pb.id = pb_as.publication_id
	ORDER BY a.birthdate DESC


