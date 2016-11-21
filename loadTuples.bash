#!/bin/bash

source dbConfig.bash
source dbUtils.bash

loadCommand1="LOAD DATA LOCAL INFILE '$csvLocation/"
#add csv file name in between loadCommand1 and 2 in for loop
loadCommand2="'
INTO TABLE " #add a table name here
loadCommand3="
FIELDS TERMINATED BY '\\t' ENCLOSED BY '' ESCAPED BY '\\\\'
LINES TERMINATED BY '\\n' STARTING BY '' 
"

function loadTuples {
        if [ -f sqlLoadFile.sql ]; then
                rm sqlLoadFile.sql
        fi

        tuples="$1"
        appendable="$2"

        OLDIFS="$IFS"
        for t in $tuples; do
                IFS=','
                set $t
                base="${loadCommand1}${1}${loadCommand2}${2}${loadCommand3}"
                echo "${base}${appendable};" >> sqlLoadFile.sql
        done
        IFS=$OLDIFS
        

	cat sqlLoadFile.sql
        sqlConn "--local-infile=1" '<' sqlLoadFile.sql 
        #--local-infile=1 option used to be able to import from csv
        echo "loaded csvs into: $tuples"
}

