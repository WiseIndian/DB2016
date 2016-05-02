#!/bin/sh

#this is relative to DB2016 directory
csvLocation=CSV
for f in `ls $csvLocation/*.csv` ; do
	suffix=.csv
	cat $f | sed 's/\r//g' > ${f%$suffix}_rem.csv
done
