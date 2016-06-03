#!/usr/bin/env python
# coding=utf-8

########################################################################
### Parse the titles.csv file, and import data to the MySQL database ###
########################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = '../CSV/titles_rem.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'title', 'translator', 'synopsis', 'note_id', 'series_id', 'series_nb', 'story_length', 'story_type', 'parent', 'language_id', 'title_graphic']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:

    title_graphic = Parse.booleanize2(row['title_graphic'])
    data.append(
		(row['id'], row['title'], row['translator'], row['synopsis'], 
		 row['note_id'], row['series_id'], row['series_nb'], 
		 row['story_length'], row['story_type'], row['parent'], 
		 row['language_id'], title_graphic)
	       ) 

Parse.writeRows(data, 'titles')
