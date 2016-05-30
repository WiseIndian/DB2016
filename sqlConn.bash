#!/bin/bash

sqlConnBase="mysql -h localhost -u group8 -ptoto123 cs322"

function sqlConn {
        sqlLoad="$sqlConnBase $@"
        echo "$sqlLoad"
        eval "$sqlLoad"
}

sqlConn "$@"
