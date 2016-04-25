#!/usr/bin/env python
# coding=utf-8

###############################################################################
### Parse the reviews.csv file, and import data to the MySQL database ###
###############################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/reviews.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'title_id', 'review_id']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:
    data.append( (row['id'], row['title_id'], row['review_id']) )


# Insert data into Database

# db = DB.Database('db4free.net','group8','toto123', 'cs322')
#
# sql = 'INSERT INTO is_reviewed_by (id, title_id, review_id) VALUES (%s, %s, %s);'
# db.insertMany(sql, data)
