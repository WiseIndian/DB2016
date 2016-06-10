
	INSERT INTO authors_referenced_by(webpage_id, author_id)
	SELECT wb.id, author_id 
	FROM Webpages_temp wb, Authors refTable 
	WHERE author_id IS NOT NULL AND 
	refTable.id = wb.author_id;
	
