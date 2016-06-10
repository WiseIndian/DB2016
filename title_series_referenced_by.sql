
	INSERT INTO title_series_referenced_by(webpage_id, title_series_id)
	SELECT wb.id, title_series_id 
	FROM Webpages_temp wb, Title_Series refTable 
	WHERE title_series_id IS NOT NULL AND 
	refTable.id = wb.title_series_id;
	
