needInstall=0
needConfig=1

if [ needInstall == 1 ]
then 
	sudo bash installSql.bash 
fi

if [ needConfig == 1 ] 
then
	bash dbConfig.bash
fi

bash loadAll.bash #load all data into the database (can take around 5 minutes)
