configFile=dbConfig.bash
source dbConfig.bash #contains needInstall and needConfig...
source countRowsNumber.bash 

function replaceConfigVar {
	# $1 should be the name of the variable in config and $2 its new value
	varToReplace="$1"
	newValue="$2"
	sed -i 's/^.*\('"$varToReplace"'\)=.*/\1='"$newValue"'/g' "$configFile" 
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


#default version of sql_mode in 5.7.16 version of mysql ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
echo "enter root password for mysql server"
old_sql_mode="$(mysql -u root -h localhost -p <<< "show variables like 'sql_mode'" | sed -n 's/^sql_mode[ \t]*\(.*\)$/\1/p')"
#get it with mysql + sed
new_sql_mode='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'

echo "enter sudo password (modifying sql_mode)."
printedSQL_MODE=0
while read -r line; do
	if [[ "$line" == *'[mysqld]'* ]] && [ $printedSQL_MODE -eq 0 ]; then
		toPrint+=$'\n'"$line"$'\n'"sql_mode = $new_sql_mode"
		printedSQL_MODE=1
	else
		toPrint+=$'\n'"$line"
	fi
done <<<"$(sed '/sql_mode/d' /etc/mysql/my.cnf)"

echo "${toPrint}" | sudo tee /etc/mysql/my.cnf 
sqlCreateCmd="
DELETE FROM mysql.user WHERE user = '$user';
DROP USER IF EXISTS '${user}'@'${host}';
FLUSH PRIVILEGES;
CREATE USER '${user}'@'${host}' IDENTIFIED BY '${password}';
DROP DATABASE IF EXISTS ${db}; 
CREATE DATABASE ${db}
	DEFAULT CHARACTER SET latin1 
	DEFAULT COLLATE latin1_swedish_ci;
GRANT ALL PRIVILEGES ON ${db}"".* TO '${user}'@'${host}';"

if [ "$needCreateTables" -eq 1 ]
then    
	echo "connecting as root to create databases!!"
	mysql -u root -h "$host" -p  <<<"$sqlCreateCmd" 
	cd Python\ Parsing				
	python createAllTables.py
	cd -
	replaceConfigVar needCreateTables 0 #If you're too lazy to change needCreateTables to 1
					#everytime just comment this line  
else 
	deleteAllRowsFromAllTables		
fi

nbRows=$(countRowsFromEveryTables cs322)
echo "number of rows in all tables: $nbRows"  #to check if deleting all rows worked

bash loadAll.bash #load all data into the database (can take around 5 minutes)

#useful feedback to check if inserting has worked well
totalRowsInDB=$(countRowsFromEveryTables cs322)
totalRowsInCSVs=`cat CSV/*.csv | wc -l`
echo "total number of rows: _ in CSVs = $totalRowsInCSVs\n         _ in DB = $totalRowsInDB"

cd server/dbServer 
ln -s ../activatorDir/activator-1.3.10-minimal/bin/activator activator
cd -
