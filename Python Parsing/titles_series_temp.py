#!/usr/bin/env python
# coding=utf-8

__author__ = 'Alexandre Connat'

#########################################################################
### Parse the authors.csv file, and import data to the MySQL database ###
#########################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/title_series.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'title', 'parent', 'note_id']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

db = DB.Database('localhost.net','group8','toto123', 'cs322')
for row in reader:
    tuple = (row['id'], row['title'], row['parent'], row['note_id'])
    sql = '''INSERT INTO Title_Series_temp (id, title, parent, note_id)
		VALUES (%s, %s, %s, %s);'''
    db.insert(sql, tuple)

