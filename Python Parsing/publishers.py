#!/usr/bin/env python
# coding=utf-8

__author__ = 'Alexandre Connat'

#####################################################################################
### Parse the publishers.csv file, and import data to the MySQL database ###
#####################################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/publishers.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'publisher_id', 'publisher_name']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:
    data.append( (row['id'], row['publisher_id'], row['publisher_name']) )


# Insert data into Database

# db = DB.Database('db4free.net','group8','toto123', 'cs322')
#
# sql = 'INSERT INTO Publisher_has_name (publisher_id, publisher_name) VALUES (%s, %s);'
# db.insertMany(sql, data)
