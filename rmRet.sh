#!/bin/sh

for f in *.csv ; do
	suffix=".csv"
	cat $f | sed 's/\r//g' > ${f%$suffix}_rem.csv
done
