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
fi
replaceConfigVar needInstall 0

if [ "$needConfig" -eq 1 ] 
then
	echo doingConfig
	echo "create database $db;
	CREATE USER '$user'@'localhost' IDENTIFIED BY '$password';
	GRANT ALL PRIVILEGES ON $db"".* TO '$user'@'localhost';" > sqlConfTmp.sql
	mysql -u root -p < sqlConfTmp.sql
fi
replaceConfigVar needConfig 0

#bash loadAll.bash #load all data into the database (can take around 5 minutes)
