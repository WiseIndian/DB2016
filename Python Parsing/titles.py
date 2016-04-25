#!/usr/bin/env python
# coding=utf-8

########################################################################
### Parse the titles.csv file, and import data to the MySQL database ###
########################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/titles.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'title', 'translator', 'synopsis', 'note_id', 'series_id', 'series_nb', 'story_length', 'story_type', 'parent', 'language_id', 'title_graphic']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:

    translator = Parse.nullize(row['translator'])
    synopsis = Parse.nullize(row['synopsis'])
    note_id = Parse.nullize(row['note_id'])
    series_id = Parse.nullize(row['series_id'])
    series_nb = Parse.nullize(row['series_nb'])
    story_length = Parse.storyLengthFormat(row['story_length'])
    story_type = Parse.storyTypeFormat(row['story_type'])
    language_id = Parse.nullize(row['language_id'])
    title_graphic = Parse.booleanize(row['title_graphic'])

    data.append( (row['id'], row['title'], translator, synopsis, note_id, series_id, series_nb, story_length, story_type, row['parent'], language_id, title_graphic) )


# Insert data into Database

# db = DB.Database('db4free.net','group8','toto123', 'cs322')
#
# sql = 'INSERT INTO Awards (id, title, date, type_id, category_id, note_id) VALUES (%s, %s, %s, %s, %s, %s);'
# db.insertMany(sql, to_db)
