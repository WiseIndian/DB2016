#!/bin/bash
#called like: bash sqlConn < aSqlScript.sql 
source dbConfig.bash

sqlConnBase="mysql -h $host -u $user -p$password $db"

pWarn="Warning: Using a password on the command line interface can be insecure"
function sqlConn { 
        sqlLoad="$sqlConnBase $@"
        output=`eval "$sqlLoad" 2>stderrFile`
	cat stderrFile | sed '/^.*'"$pWarn"'.*$/d' 1>&2 ;
	#the following redirects stderr to a file so that we can
	#ignore $pWarn which really pollutes the terminal when
	# we're just trying to debug our program:
	#"$sqlLoad" 2>stderrFile`
        #cat stderrFile | sed '/^.*'"$pWarn"'.*$/d' 1>&2 ;
}

sqlConn "$@"
