#!/usr/bin/env python
# coding=utf-8

__author__ = 'Alexandre Connat'

######################################################################################
### Parse the publications_content.csv file, and import data to the MySQL database ###
######################################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = '../CSV/publications_content_rem.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'title_id', 'publication_id']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:
    data.append( (row['title_id'], row['publication_id']) )

writeRows(data, 'publications_content')
