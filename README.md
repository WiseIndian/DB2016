# DB2016
The following instructions are for linux, but they might work on OSX
which also support bash scripts which we used.
Maybe Windows would be compatible soon too(or is with cygwin)!
This project is in multiple parts:
_ the loading of tables that happens by executing:
	 bash main.bash
before doing that you need to check if in dbConfig.bash the needCreateTables variable is set to 1
The idea of the main.bash script is:
	It will drop the database cs322 if it exists and create a user group8
	then it will call Python\ Parsing/createAllTables.py to create the tables in the DB.
	then it will call loadAll.bash that is in charge of loading data from CSVs to the database.
the execution takes about 5 minuts all in all.

to connect to the database you basically have to do mysql -u group8 -h localhost -ptoto123 cs322.

The newest versions of the queries we created are inside the scala file:
	server/dbServer/app/controllers/Application.scala
they are all just look for the sentence:
	 SELECT a.name AS "oldest author name", pb_date, 
with CTRL+F you'll find them all :)
They are all wrapped inside scala string quotes so they are not very readible.

Then once you've filled and created the tables, you can launch the server.
Normally you just need the jdk8 and jre8 installed and it should work.

Normally main.bash should have created a soft link (see end of main.bash) that links 
activator from the bin directory of activator(its a scala play bash script to install
scala play).
To launch the server you just have to go server/dbServer/ (it's important to be in this directory
with the terminal so that the following works)
then just have to do bash activator run
this is going to install scala play framework and then run the server.
Then you can access the server on localhost:9000 via a browser like firefox for example.
