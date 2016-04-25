#!/usr/bin/env python
# coding=utf-8

#############################################################################
### Parse the award_types.csv file, and import data to the MySQL database ###
#############################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/award_types.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'code', 'name', 'note_id', 'awarded_by', 'awarded_for', 'short_name', 'is_poll', 'non_genre']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:

    code = Parse.nullize(row['code'])
    note_id = Parse.nullize(row['note_id'])
    awarded_by = Parse.nullize(row['awarded_by'])
    is_poll = Parse.booleanize(row['is_poll'])
    non_genre = Parse.booleanize(row['non_genre'])

    data.append( (row['id'], code, row['name'], note_id, awarded_by, row['short_name'], is_poll, non_genre) )

for d in data:
    print d


# Insert data into Database

# db = DB.Database('db4free.net','group8','toto123', 'cs322')
#
# sql = 'INSERT INTO Awards_Type (id, title, date, type_id, category_id, note_id) VALUES (%s, %s, %s, %s, %s, %s);'
# db.insertMany(sql, to_db)
