configFile=dbConfig.bash
source "$configFile" #contains needInstall and needConfig...

function replaceConfigVar {
	# $1 should be the name of the variable in config and $2 its new value
	varToReplace="$1"
	newValue="$2"
	sed -i 's/^.*\('"$varToReplace"'\)=.*/\1='"$newValue"'/g' "$configFile" 
}

function countRowsFromEveryTables { # can be used as useful feedback
        bash countRowsNumber.bash "$database"
}

function deleteAllRowsFromAllTables {
        sqlConn '<' deleteAll.sql
        echo "deleted all rows"
}

if [ "$needInstall" -eq 1 ]
then 
	echo doingInstall
	sudo bash installSql.bash 
	sudo apt-get install python-mysqldb #for python scripts in Python\ Parsing
	replaceConfigVar needInstall 0
fi

sqlCreateCmd="
DELETE FROM mysql.user WHERE user = '$user';
DROP USER '${user}'@'${host}';
FLUSH PRIVILEGES;
CREATE USER '${user}'@'${host}' IDENTIFIED BY '${password}';
DROP DATABASE IF EXISTS ${db}; 
CREATE DATABASE ${db};
GRANT ALL PRIVILEGES ON ${db}"".* TO '${user}'@'${host}';" 

if [ "$needCreateTables" -eq 1 ]
then    
	echo "$sqlCreateCmd" > tmpSql.sql
	echo "connecting as root to create databases!!"
	mysql -u root -h "$host" -p  < tmpSql.sql #need root here sorry a bit annoying
	cd Python\ Parsing				#but its painful o.w.
	python createAllTables.py
	cd -
	replaceConfigVar needCreateTables 0
else 
	deleteAllRowsFromAllTables		
fi

nbRows=$(countRowsFromEveryTables)
echo "number of rows in all tables: $nbRows"  #to check if deleting all rows worked

bash loadAll.bash #load all data into the database (can take around 5 minutes)

#useful feedback to check if inserting has worked well
totalRowsInDB=$(countRowsFromEveryTables)
totalRowsInCSVs=`cat CSV/*.csv | wc -l`
echo "total number of rows: _ in CSVs = $totalRowsInCSVs\n         _ in DB = $totalRowsInDB"


