
	INSERT INTO titles_referenced_by(webpage_id, title_id)
	SELECT wb.id, title_id 
	FROM Webpages_temp wb, Titles refTable 
	WHERE title_id IS NOT NULL AND 
	refTable.id = wb.title_id;
	
