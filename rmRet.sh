#!/bin/sh

csvLocation=CSV

#this is relative to DB2016 directory
function rmRet {
	f="$1"
	suffix=.csv
	cat $f | sed 's/\r//g' > ${f%$suffix}_rem.csv
}

function rmRetAllFiles {
	for f in `ls $csvLocation/*.csv` ; do
		rmRet $f
	done
}
