#!/usr/bin/env python
# coding=utf-8

###############################################################################
### Parse the titles_tag.csv file, and import data to the MySQL database ###
###############################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = '../CSV/titles_tag_rem.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'tag_id', 'title_id']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:
    data.append( (row['title_id'], row['tag_id']) )

with open('../CSV/titles_tagCLEAN.csv','w') as out:
    csv_out = csv.writer(out, delimiter='\t')
    for tuple in data:
        csv_out.writerow(tuple)

