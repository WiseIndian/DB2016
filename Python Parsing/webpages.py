#!/usr/bin/env python
# coding=utf-8

##########################################################################
### Parse the webpages.csv file, and import data to the MySQL database ###
##########################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/webpages.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'author_id', 'publisher_id', 'url', 'publication_series_id', 'title_id', 'award_type_id', 'title_series_id', 'award_category_id']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:

    author_id = Parse.nullize(row['author_id'])
    publisher_id = Parse.nullize(row['publisher_id'])
    publication_series_id = Parse.nullize(row['publication_series_id'])
    title_id = Parse.nullize(row['title_id'])
    award_type_id = Parse.nullize(row['award_type_id'])
    title_series_id = Parse.nullize(row['title_series_id'])
    award_category_id = Parse.nullize(row['award_category_id'])
    url = Parse.nullize(row['url'])

    data.append( (row['id'], author_id, publisher_id, publication_series_id, title_id, award_type_id, title_series_id, award_category_id, url) )


# Insert data into Database

# db = DB.Database('db4free.net','group8','toto123', 'cs322')
#
# sql = 'INSERT INTO Awards (id, title, date, type_id, category_id, note_id) VALUES (%s, %s, %s, %s, %s, %s);'
# db.insertMany(sql, to_db)
