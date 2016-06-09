#!/bin/bash
#called with one argument "$1" that should be equal to the database name 


function sqlConn { # "$@" could be < aSqlScript.sql 
        bash sqlConn.bash "$@"
}

function countRowsFromNotTempTables {
  sqlQuery="SELECT SUM(Tables.TABLE_ROWS) FROM INFORMATION_SCHEMA.TABLES
     AS Tables WHERE TABLE_SCHEMA = '$1' AND
     NOT Tables.TABLE_NAME REGEXP '^.*temp.*$';"
  echo "$sqlQuery" > tempSqlScript.sql 
  sqlConn < tempSqlScript.sql
}

function countRowsFromEveryTables { # can be used as useful feedback
        sqlQuery="SELECT SUM(TABLE_ROWS)
         FROM INFORMATION_SCHEMA.TABLES 
         WHERE TABLE_SCHEMA = '$1';"
        echo "$sqlQuery" > tempSqlScript.sql
        sqlConn < tempSqlScript.sql | grep '^[0-9][0-9]*$'
        #could rm tempSqlScript.sql if we wanted
}

