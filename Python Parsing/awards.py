#!/usr/bin/env python
# coding=utf-8

__author__ = 'Alexandre Connat'

########################################################################
### Parse the awards.csv file, and import data to the MySQL database ###
########################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = '../CSV/awards_rem.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'title', 'date', 'type_code', 'type_id', 'category_id', 'note_id']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

#here we omit type code because that we want as end input of load data
data = []
for row in reader:
    data.append( (row['id'], row['title'], row['date'],
		 row['type_id'], row['category_id'], row['note_id']) )

with open('../CSV/awardsCLEAN.csv','w') as out:
    csv_out = csv.writer(out, delimiter='\t')
    for tuple in data:
        csv_out.writerow(tuple)

