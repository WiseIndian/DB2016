sqlConnBase="mysql -h localhost -u group8 --password=toto123"
dbName="cs322"

function sqlConn {
        sqlLoad="$sqlConnBase $@ $dbName"
        echo "$sqlLoad"
        eval "$sqLoad"
}

