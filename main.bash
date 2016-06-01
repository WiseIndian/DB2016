configFile=dbConfig.bash
source "$configFile" #contains needInstall and needConfig...

function replaceConfigVar {
	# $1 should be the name of the variable in config and $2 its new value
	varToReplace="$1"
	newValue="$2"
	sed -i 's/^.*\('"$varToReplace"'\)=.*/\1='"$newValue"'/g' "$configFile" 
}

if [ "$needInstall" -eq 1 ]
then 
	echo doingInstall
	sudo bash installSql.bash 
	sudo apt-get install python-mysqldb #for python scripts in Python\ Parsing
fi
replaceConfigVar needInstall 0

if [ "$needConfig" -eq 1 ] 
then
	echo doingConfig
	echo "create database $db;
	CREATE USER '$user'@'localhost' IDENTIFIED BY '$password';
	GRANT ALL PRIVILEGES ON $db"".* TO '$user'@'localhost';" > sqlConfTmp.sql
	echo "connecting as root to create user group8 and create database!!"
	mysql -u root -h "$host" -p < sqlConfTmp.sql
fi
replaceConfigVar needConfig 0

if [ "$needCreateTables" -eq 1 ]
then    
	echo "DROP DATABASE IF EXISTS $db; 
	create database $db;
	GRANT ALL PRIVILEGES ON $db"".* TO '$user'@'localhost';" > tmpSql.sql
	echo "connecting as root to create databases!!"
	mysql -u root -h "$host" -p  < tmpSql.sql #need root here sorry a bit annoying
	cd Python\ Parsing				#but its painful o.w.
	python createAllTables.py
	cd -
fi
replaceConfigVar needCreateTables 0

#bash loadAll.bash #load all data into the database (can take around 5 minutes)
