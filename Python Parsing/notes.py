#!/usr/bin/env python
# coding=utf-8

#######################################################################
### Parse the notes.csv file, and import data to the MySQL database ###
#######################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/notes.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'note']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

db = DB.Database('localhost','group8','toto123', 'cs322')

for row in reader:
    tuple = (row['id'],row['note'])
    sql = 'INSERT INTO Notes (id, note) VALUES (%s, %s);'
    db.insert(sql, tuple)