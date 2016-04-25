#!/usr/bin/env python
# coding=utf-8

__author__ = 'Alexandre Connat'

#####################################################################################
### Parse the publications_series.csv file, and import data to the MySQL database ###
#####################################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/publications_series.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'publication_series_id', 'publication_series_name']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:
    data.append( (row['id'], row['publication_series_id'], row['publication_series_name']) )


# Insert data into Database

# db = DB.Database('db4free.net','group8','toto123', 'cs322')
#
# sql = 'INSERT INTO Publication_Serie_has_name (publication_series_id, publication_series_name) VALUES (%s, %s);'
# db.insertMany(sql, data)
