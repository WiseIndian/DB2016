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

db = DB.Database('localhost', 'group8', 'toto123', 'cs322')

# this query should populate the Authors table if Authors_temp 
# has already been populated.
db.query('''
	INSERT INTO
	Authors (id,  name,  legal_name ,  last_name,
	  pseudo,  birthplace,  birthdate,  deathdate,  email, 
	  img_link,  language_id,  note)
	SELECT a.id, a.name, a.legal_name, a.last_name, a.pseudo, a.birthplace,
        a.birthdate, a.deathdate, a.email, a.img_link, a.language_id, NULL
	FROM Authors_temp a
	WHERE a.note_id = NULL
	UNION
	SELECT a.id, a.name, a.legal_name, a.last_name, a.pseudo, a.birthplace,
		a.birthdate, a.deathdate, a.email, a.img_link, a.language_id, n.note
	FROM Authors_temp a, Notes n
	WHERE a.note_id = n.id;''')
	

