
	INSERT INTO publishers_referenced_by(webpage_id, publisher_id)
	SELECT wb.id, publisher_id 
	FROM Webpages_temp wb, Publishers refTable 
	WHERE publisher_id IS NOT NULL AND 
	refTable.id = wb.publisher_id;
	
