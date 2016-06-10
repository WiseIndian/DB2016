
	INSERT INTO award_types_referenced_by(webpage_id, award_type_id)
	SELECT wb.id, award_type_id 
	FROM Webpages_temp wb, Award_Types refTable 
	WHERE award_type_id IS NOT NULL AND 
	refTable.id = wb.award_type_id;
	
