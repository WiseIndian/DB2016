#!/bin/bash
#called with one argument "$1" that should be equal to the database name 


function sqlConn { # "$@" could be < aSqlScript.sql 
        bash sqlConn.bash "$@"
}


function countRowsFromEveryTables { # can be used as useful feedback
        sqlQuery="SELECT SUM(TABLE_ROWS)
         FROM INFORMATION_SCHEMA.TABLES 
         WHERE TABLE_SCHEMA = '$1';"
        echo "$sqlQuery" > tempSqlScript.sql
        sqlConn < tempSqlScript.sql | sed -n '/^[0-9]\+$/p'
        #could rm tempSqlScript.sql if we wanted
}

countRowsFromEveryTables "$1"
