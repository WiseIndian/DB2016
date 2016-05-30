#!/bin/bash
#called like: bash sqlConn < aSqlScript.sql 
source dbConfig.bash

sqlConnBase="mysql -h $host -u $user -p$password $db"

function sqlConn { 
        sqlLoad="$sqlConnBase $@"
        echo "$sqlLoad"
        eval "$sqlLoad"
}

sqlConn "$@"
