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

filename = '../CSV/publications_rem.csv'
f = open(filename, 'rU')
f.seek(0)

fields = ['id', 'title', 'date', 'publisher_id', 'nb_pages', 'packaging_type', 'publication_type', 'isbn', 'cover_img', 'price', 'note_id', 'publication_series_id', 'publication_series_nb']
reader = csv.DictReader(f, dialect='excel-tab', fieldnames=fields)

data = []
for row in reader:

    nb_pages = row['nb_pages']
    if nb_pages != '\N':
        nb_pages = re.sub('[^0-9]', '', nb_pages) # Only keep integers within the number of pages

    publication_type = Parse.publicationTypeFormat(row['publication_type'])

    price = row['price']
    currency = '\N'
    if price != '\N':
        if hex(ord(price[0])) == '0x24':
            currency = 'DOLLAR'
        elif hex(ord(price[0])) == '0xa3':
            currency = 'POUND'
        else:
            currency = '\N'
        price = price[1:]

    tuple = ( row['id'], row['title'], row['date'], row['publisher_id'], nb_pages, row['packaging_type'], publication_type, row['isbn'], row['cover_img'], currency, price, row['note_id'], row['publication_series_id'], row['publication_series_nb'] )
    data.append(tuple)


# Create a clean CSV file
writeRows(data, 'publications')
