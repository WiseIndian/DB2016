SELECT year, COUNT(*) FROM
  (SELECT id, YEAR(pb_date) AS year  FROM Publications) AS Res1
GROUP BY year;

