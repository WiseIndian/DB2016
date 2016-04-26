#!/usr/bin/env python
# coding=utf-8

###########################################################################
### Parse the languages.csv file, and import data to the MySQL database ###
###########################################################################

import Database as DB
import Parse as Parse
import csv

# Parse data from csv file

filename = 'Books/languages.csv'
f = open(filename, 'rU')
f.seek(0) # Positionne le curseur au tout début du fichier

fields = ['id', 'name', 'code', 'script']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

db = DB.Database('localhost','group8','toto123', 'cs322')

for row in reader:
	tuple = (row['id'], row['name'], row['code'], row['script'])
	sql = 'INSERT INTO Languages (id, name, code, script) VALUES (%s, %s, %s, %s)'
	db.insert(sql, tuple)

