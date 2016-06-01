#!/usr/bin/env python
# coding=utf-8

__author__ = 'Alexandre Connat'

#########################################################################
### Parse the authors.csv file, and import data to the MySQL database ###
#########################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/authors.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'name', 'legal_name', 'last_name', 'pseudo', 'birthplace', 'birthdate', 'deathdate', 'email', 'img', 'language_id', 'note_id']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:
    tuple = ( row['id'], row['name'], row['legal_name'], row['last_name'], row['pseudo'], row['birthplace'], row['birthdate'], row['deathdate'], row['email'], row['img'], row['language_id'], row['note_id'] )
    data.append(tuple)


# Create a clean CSV file

with open('authorsCLEAN.csv','w') as out:
    csv_out = csv.writer(out, delimiter='\t')

    for tuple in data:
        csv_out.writerow(tuple)
