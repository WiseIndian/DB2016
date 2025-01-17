#!/usr/bin/env python
# coding=utf-8

######################################################################
### Parse the tags.csv file, and import data to the MySQL database ###
######################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/tags.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'tag']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:
    data.append((row['id'],row['tag']))

# Insert data into Database

# db = DB.Database('db4free.net','group8','toto123', 'cs322')
#
# sql = 'INSERT INTO Tags (id, tag) VALUES (%s, %s);'
# db.insertMany(sql, data)
