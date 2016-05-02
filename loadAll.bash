#!/bin/bash

#you have to execute this script in base of repo i.e. from DB2016
#and that because the load*.sql files use paths relative to the current directory!

csvLocation=CSV #don't put a directory name containing spaces it won't work

lsOutput=`ls $csvLocation/*_rem.csv` 
#testing if $lsOutput is an empty string`man test` for more info on this if
if [ -z ${lsOutput:0:20} ]; then #print 21 first characters of $lsOutput and see if its empty
	rm csvLocation/*_rem.csv #we want to start with a fresh output from rmRet.sh
fi

sh rmRet.sh #delete ^M and other bullshit carriage return \r...

#--local-infile=1 option used to be able to import from csv(which is done in loadNotes.sql)
mysql -h localhost -u group8 --password=toto123 cs322 < loadNotes.sql --local-infile=1

