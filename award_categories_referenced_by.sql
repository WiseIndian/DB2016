
	INSERT INTO award_categories_referenced_by(webpage_id, award_category_id)
	SELECT wb.id, award_category_id 
	FROM Webpages_temp wb, Award_Categories refTable 
	WHERE award_category_id IS NOT NULL AND 
	refTable.id = wb.award_category_id;
	
