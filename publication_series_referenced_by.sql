
	INSERT INTO publication_series_referenced_by(webpage_id, publication_series_id)
	SELECT wb.id, publication_series_id 
	FROM Webpages_temp wb, Publication_Series refTable 
	WHERE publication_series_id IS NOT NULL AND 
	refTable.id = wb.publication_series_id;
	
