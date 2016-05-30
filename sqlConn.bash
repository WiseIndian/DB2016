#!/bin/bash
#called like: bash sqlConn < aSqlScript.sql 
source dbConfig.bash

sqlConnBase="mysql -h $host -u $user -p$password $db"

pWarn="Warning: Using a password on the command line interface can be insecure"
function sqlConn { 
	if  [ -z "$@" ]; then
		sqlCmd="$sqlConnBase $@"
	else 
		sqlCmd="$sqlConnBase"
	fi
        `eval "$sqlCmd" 2>stderrFile`
	cat stderrFile | sed '/^.*'"$pWarn"'.*$/d' 1>&2 ;
	#the before code redirects stderr to a file so that we can
	#ignore $pWarn which really pollutes the terminal when
	# we're just trying to debug our program:
}

if [ ! -z "$@" ]; then
	sqlConn "$@"
else 
	eval "$sqlConnBase"
fi
