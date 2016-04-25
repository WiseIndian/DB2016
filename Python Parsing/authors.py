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

    legal_name = Parse.nullize(row['legal_name'])
    pseudo = Parse.nullize(row['pseudo'])
    birthplace = Parse.nullize(row['birthplace'])
    birthdate = Parse.nullize(row['birthdate'])
    deathdate = Parse.nullize(row['deathdate'])
    email = Parse.nullize(row['email'])
    img = Parse.nullize(row['img'])
    language_id = Parse.nullize(row['language_id'])
    note_id = Parse.nullize(row['note_id'])

    data.append( (row['id'], row['name'], legal_name, row['last_name'], pseudo, birthplace, birthdate, deathdate, email, img, language_id, note_id) )


# Insert data into Database

# db = DB.Database('db4free.net','group8','toto123', 'cs322')
#
# sql = 'INSERT INTO Authors (id, name, ...) VALUES (%s, %s, ...);'
# db.insertMany(sql, data)
