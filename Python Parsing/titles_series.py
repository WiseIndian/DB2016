#!/usr/bin/env python
# coding=utf-8

###############################################################################
### Parse the titles_series.csv file, and import data to the MySQL database ###
###############################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

db = DB.Database('localhost','group8','toto123', 'cs322')
# query to populate Title_Seires using Title_Series_temp
db.query('''    INSERT INTO Title_Series (id, title_id, parent, note) 
		SELECT t.id, t.title, t.parent, n.note
		FROM Title_Series_temp t, Notes n
		WHERE t.note_id = n.id
		UNION
		SELECT t.id, t.title, t.parent, NULL
		FROM Title_Series_temp t
		WHERE t.note_id = NULL; ''')

