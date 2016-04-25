#!/usr/bin/env python
# coding=utf-8

__author__ = 'Alexandre Connat'

######################################################################################
### Parse the publications_authors.csv file, and import data to the MySQL database ###
######################################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/publications_authors.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'publication_id', 'author_id']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:
    data.append( (row['id'], row['publication_id'], row['author_id']) )

for d in data:
    print d

# Insert data into Database

# db = DB.Database('db4free.net','group8','toto123', 'cs322')
#
# sql = 'INSERT INTO Authors (id, name, ...) VALUES (%s, %s, ...);'
# db.insertMany(sql, data)
