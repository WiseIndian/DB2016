#!/usr/bin/env python
# coding=utf-8

###############################################################################
### Parse the titles_awards.csv file, and import data to the MySQL database ###
###############################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/titles_awards.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'award_id', 'title_id']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:
    data.append( (row['id'], row['award_id'], row['title_id']) )


# Insert data into Database

# db = DB.Database('db4free.net','group8','toto123', 'cs322')
#
# sql = 'INSERT INTO has_won_award (title_id, award_id) VALUES (%s, %s);'
# db.insertMany(sql, data)
