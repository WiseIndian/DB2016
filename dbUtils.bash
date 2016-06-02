#!/bin/bash
source dbConfig.bash

function sqlConn { # "$@" could be < aSqlScript.sql 
        bash sqlConn.bash "$@"
}

function countRowsFromEveryTables { # can be used as useful feedback
        bash countRowsNumber.bash "$database"
}

