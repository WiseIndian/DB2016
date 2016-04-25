#!/usr/bin/env python
# coding=utf-8

##################################################################################
### Parse the award_categories.csv file, and import data to the MySQL database ###
##################################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/award_categories.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'name', 'type_id', 'order', 'note_id']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:

    order = Parse.nullize(row['order'])
    note_id = Parse.nullize(row['note_id'])

    data.append( (row['id'], row['name'], row['type_id'], order, note_id) )


# Insert data into Database

# db = DB.Database('db4free.net','group8','toto123', 'cs322')
#
# sql = 'INSERT INTO Awards (id, title, date, type_id, category_id, note_id) VALUES (%s, %s, %s, %s, %s, %s);'
# db.insertMany(sql, to_db)
