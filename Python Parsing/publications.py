#!/usr/bin/env python
# coding=utf-8

__author__ = 'Alexandre Connat'

##############################################################################
### Parse the publications.csv file, and import data to the MySQL database ###
##############################################################################

import Database as DB
import Parse as Parse
import csv
import re

# Parse data from csv file

filename = 'Books/publications.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'title', 'date', 'publisher_id', 'nb_pages', 'packaging_type', 'publication_type', 'isbn', 'cover_img', 'price', 'note_id', 'publication_series_id', 'publication_series_nb']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:

    publisher_id = Parse.nullize(row['publisher_id'])

    nb_pages = Parse.nullize(row['nb_pages'])
    if nb_pages:
        nb_pages = re.sub('[^0-9]', '', nb_pages) # Only keep integers within the number of pages

    publication_type = Parse.publicationTypeFormat(row['publication_type'])
    isbn = Parse.nullize(row['isbn'])
    cover_img = Parse.nullize(row['cover_img'])

    price = Parse.nullize(row['price'])
    currency = None
    if price:
        if hex(ord(price[0])) == '0x24':
            currency = 'DOLLAR'
        elif hex(ord(price[0])) == '0xa3':
            currency = 'POUND'
        else:
            currency = None
        price = price[1:]

    note_id = Parse.nullize(row['note_id'])
    publication_series_id = Parse.nullize(row['publication_series_id'])
    publication_series_nb = Parse.nullize(row['publication_series_nb'])

    data.append( (row['id'], row['title'], row['date'], publisher_id, nb_pages, row['packaging_type'], publication_type, isbn, cover_img, price, currency, note_id, publication_series_id, publication_series_nb) )


# Insert data into Database

# db = DB.Database('db4free.net','group8','toto123', 'cs322')
#
# sql = 'INSERT INTO Authors (id, name, ...) VALUES (%s, %s, ...);'
# db.insertMany(sql, data)

# ATTENTION : Currency est une ENUM !!!
