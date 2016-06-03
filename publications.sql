INSERT INTO Publications(id, title, pb_date, publisher_id, nb_pages, packaging_type,
		publication_type, isbn, cover_img, currency, price,
		note, publication_series_id, publication_series_number)
SELECT pb.id, title, pb_date, publisher_id, nb_pages, packaging_type,
        publication_type, isbn, cover_img, currency, price, note,
	publication_series_id, publication_series_number
FROM Publications_temp pb, Notes n
WHERE pb.note_id = n.id
UNION
SELECT id, title, pb_date, publisher_id, nb_pages, packaging_type,
        publication_type, isbn, cover_img, currency, price, NULL,
	publication_series_id, publication_series_number
FROM Publications_temp
WHERE note_id IS NULL
;

