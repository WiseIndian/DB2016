#!/bin/bash

user="group8"
host="localhost"
password="toto123"
db="cs322"
database="$db"


echo "create database $db;
CREATE USER '$user'@'localhost' IDENTIFIED BY '$password';
GRANT ALL PRIVILEGES ON $db"".* TO '$user'@'localhost';" > sqlConfTmp.sql

mysql -u root -p < sqlConfTmp.sql 
