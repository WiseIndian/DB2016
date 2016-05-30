#!/bin/bash

if [ "$1" == "user" ] || [ "$1" == "u" ]
then	echo group8
elif [ "$1" == "host" ] || [ "$1" == "h" ]
then	echo localhost
elif [ "$1" == "password" ] || [ "$1" == "p" ]
then	echo toto123
elif [ "$1" == "db" ] || [ "$1" == "database" ] 
then	echo cs322
else 
	&>2 echo "error unknown input of getDBinfos.bash"
fi
 
