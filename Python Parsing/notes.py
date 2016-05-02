#!/usr/bin/env python
# coding=utf-8

#######################################################################
### Parse the notes.csv file, and import data to the MySQL database ###
#######################################################################


import Parse as Parse
import csv

import MySQLdb 

# Parse data from csv file

filename = 'Books/notes.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'note']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

db = MySQLdb.connect('localhost','group8',
	 'toto123', 'cs322', local_infile = 1)
db.commit()
cursor = db.cursor()


def multiInsert(): 
	for row in reader:
	    tuple = (row['id'],row['note'])
	    sql = 'INSERT INTO Notes (id, note) VALUES (%s, %s);'
	    db.insert(sql, tuple)

def loadNotes():#TODO: remove \r from csvs
	sql = '''
	LOAD DATA LOCAL INFILE 'Books/notes.csv'
	INTO TABLE Notes
	FIELDS
                  TERMINATED BY '\t'
                  ENCLOSED BY ''
                  ESCAPED BY '\\'
         LINES
                    STARTING BY ''
                    TERMINATED BY '\n'
	'''
	cursor.execute(sql)
	

loadNotes()
