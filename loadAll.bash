#!/bin/bash

#you have to execute this script in base of repo i.e. from DB2016
#and that because the load*.sql files use paths relative to the current directory!

csvLocation=CSV #don't put a directory name containing spaces it won't work
sqlConnBase="mysql -h localhost -u group8 --password=toto123"
dbName="cs322"

lsOutput=`ls $csvLocation/*_rem.csv` 
#testing if $lsOutput is an empty string`man test` for more info on this if
if [ ! -z ${lsOutput:0:20} ]; then #print 21 first characters of $lsOutput and see if its empty
	rm "$csvLocation"/*_rem.csv #we want to start with a fresh output from rmRet.sh
fi

sh rmRet.sh #delete ^M and other bullshit carriage return \r...

loadCommand1="LOAD DATA LOCAL INFILE '"$csvLocation"/"
#add csv file name in between loadCommand1 and 2 in for loop
loadCommand2="'
INTO TABLE " #add a table name here
loadCommand3="
CHARACTER SET UTF8
FIELDS TERMINATED BY '\\t' ENCLOSED BY '' ESCAPED BY '\\\\'
LINES TERMINATED BY '\\n' STARTING BY '';
"

function sqlConn {
	sqlLoad="$sqlConnBase $@ $dbName"
	echo "$sqlLoad"
	eval "$sqLoad"
}
#call this function like:
#loadTuples "csv1.csv,Table1 csv2.csv,Table2" "<additional-sql-code-to-append-to-loadCommand3>"
#tuples is "csv1.csv,...,Table2" 
#and appendable is "<additional-sql-code-to-append-to-loadCommand3>"
function loadTuples { 
	OLDIFS=$IFS
	tuples="$1" #load arguments of loadTuples into tuples
	appendable="$2" #will be an empty string if nothing specified
	
	if [ -f sqlLoadFile.sql ]; then
		rm sqlLoadFile.sql
	fi

	for t in $tuples; do 
		IFS=","
		set -- $t  
		#set $1, $2 ... to all comma separated values
		temp1="$loadCommand1""$1"
		temp2="$loadCommand2""$2""$loadCommand3"
		sqlCmd="$temp1""$temp2""$appendable"
		echo "$sqlCmd"
		echo "$sqlCmd" >> sqlLoadFile.sql
	done
	sqlConn " --local-infile=1 < sqlLoadFile.sql"
	#--local-infile=1 option used to be able to import from csv
	IFS=$OLDIFS
}

function deleteFromTables {
	tables="$@" #argument can be like "Notes Authors"
	if [ -f sqlDeleteFile ]; then
		rm sqlDeleteFile
	fi

	for t in $tables; do
		IFS=","
		set -- $t
		echo "DELETE FROM $t" >> sqlDeleteFile
	done
	sqlConn " < sqlDeleteFile"
}

function deleteAllRowsFromAllTables {
	sqlConn " < deleteAll.sql"
}

deleteAllRowsFromAllTables
#calling loadTuples
loadTuples "notes_rem.csv,Notes
	    languages_rem.csv,Languages 
	    authors_rem.csv,Authors_temp"
 
sqlConn " < authors.sql" #checked

loadTuples "title_series_rem.csv,Title_Series_temp"
sqlConn " < title_series.sql" #checked

loadTuples "titles_rem.csv,Titles_temp"
sqlConn  " < titles.sql"
sqlConn " < title_is_translated_in.sql"
loadTuples "reviews_rem.csv,title_is_reviewed_by 
	    titles_series_rem.csv,title_is_part_of_Title_Series
	    award_types_rem.csv,Award_Types_temp"
sqlConn " < awardsTypes.sql"
loadTuples "award_categories_rem.csv,Award_Categories_temp"
sqlConn " < awardCategories.sql"
loadTuples "awards_rem.csv,Awards_temp"
sqlConn " < awards.sql"
#see http://stackoverflow.com/questions/4202564/how-to-insert-selected-columns-from-csv-file-to-mysql-using-load-data-infile  
#for following 2 lines of code
selectCsvColumns="(@col1, @col2, @col3) set award_id=@col2, title_id=@col3"
loadTuples "titles_awards_rem.csv,title_wins_award" "$selectCsvColumns"
#	tags = '''
#	CREATE TABLE Tags (
#	id INTEGER,
#	name VARCHAR(255),
#	PRIMARY KEY (id)
#	) ENGINE=InnoDB;'''
#	createTable(tags)
#
#	title_has_tag = '''
#	CREATE TABLE title_has_tag (
#	tag_id  INTEGER,
#	title_id INTEGER,
#	PRIMARY KEY (tag_id, title_id),
#	FOREIGN KEY (tag_id) REFERENCES Tags(id) ON DELETE CASCADE,
#	FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(title_has_tag)
#
#	publishers_temp = '''
#	CREATE TABLE Publishers_temp (
#	  id INTEGER,
#	  name VARCHAR(255),
#	  note_id INTEGER,
#	  PRIMARY KEY (id),
#	  FOREIGN KEY (note_id) REFERENCES Notes(id)  ON DELETE SET NULL
#	) ENGINE=InnoDB;'''
#	createTable(publishers_temp)
#
#	publishers = '''
#	CREATE TABLE Publishers (
#	  id INTEGER,
#	  name VARCHAR(255),
#	  note TEXT,
#	  PRIMARY KEY (id)
#	) ENGINE=InnoDB;'''
#	createTable(publishers)
#
#	publication_series_temp = '''
#	CREATE TABLE Publication_Series_temp (
#	  id INTEGER,
#	  name VARCHAR(255),
#	  note_id INTEGER,
#	  PRIMARY KEY (id),
#	  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL
#	) ENGINE=InnoDB;'''
#	createTable(publication_series_temp)
#
#	publication_series = '''
#	CREATE TABLE Publication_Series (
#	  id INTEGER,
#	  name VARCHAR(255),
#	  note TEXT,
#	  PRIMARY KEY (id)
#	) ENGINE=InnoDB;'''
#	createTable(publication_series)
#
#
#	publications_temp = '''
#	CREATE TABLE Publications_temp (
#	  id INTEGER,
#	  /* we should use a view/relationship that just describes the many to many relationship
#	   * and references of Titles id and Publications id, see todoFromDeliv1Feedback file(on github)
#	   * for more info on how to do it.
#	   */
#	  title VARCHAR(255), /*stay closer to definition of the csv file as described in todoFromDeliv1Feedback */
#	  pb_date DATE,
#	  publisher_id INTEGER,
#	  nb_pages INTEGER,
#	  packaging_type VARCHAR(255),
#	  publication_type ENUM('ANTHOLOGY', 'COLLECTION', 'MAGAZINE', 'NONFICTION',
#				 'NOVEL', 'OMNIBUS', 'FANZINE', 'CHAPBOOK'),
#	  isbn INTEGER,
#	  cover_img VARCHAR(255),
#	  price DECIMAL(6, 5), /*valeurs un peu arbitraires, mais on peut imaginer qu'un livre 
#				 aura pas un prix > un million dans n'importe quelle currency?*/
#	  currency VARCHAR(1),
#	  note_id INTEGER,
#	  PRIMARY KEY (id),
#	  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
#	  FOREIGN KEY (publisher_id) REFERENCES Publishers(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(publications_temp)
#
#	publications = '''
#	CREATE TABLE Publications (
#	  id INTEGER,
#	  /* we should use a view/relationship that just describes the many to many relationship
#	   * and references of Titles id and Publications id, see todoFromDeliv1Feedback file(on github)
#	   * for more info on how to do it.
#	   */
#	  title VARCHAR(255), /*stay closer to definition of the csv file as described in todoFromDeliv1Feedback */
#	  pb_date DATE,
#	  publisher_id INTEGER,
#	  nb_pages INTEGER,
#	  packaging_type VARCHAR(255),
#	  publication_type ENUM('ANTHOLOGY', 'COLLECTION', 'MAGAZINE', 'NONFICTION',
#				 'NOVEL', 'OMNIBUS', 'FANZINE', 'CHAPBOOK'),
#	  isbn INTEGER,
#	  cover_img VARCHAR(255),
#	  price DECIMAL(6, 5), /*valeurs un peu arbitraires, mais on peut imaginer qu'un livre 
#				 aura pas un prix > un million dans n'importe quelle currency?*/
#	  currency VARCHAR(1),
#	  note TEXT,
#	  PRIMARY KEY (id),
#	  FOREIGN KEY (publisher_id) REFERENCES Publishers(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(publications)
#
#	publication_is_of_Publication_Series = '''
#	CREATE TABLE Publication_is_of_Publication_Series (
#	publication_id  INTEGER,
#	series_id INTEGER,
#	series_number INTEGER,
#	PRIMARY KEY (publication_id),
#	FOREIGN KEY (publication_id) REFERENCES Publications(id) ON DELETE CASCADE,
#	FOREIGN KEY (series_id) REFERENCES Publication_Series(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(publication_is_of_Publication_Series)
#
#
#	authors_have_publications = '''
#	CREATE TABLE authors_have_publications (
#	  author_id  INTEGER,
#	  pub_id INTEGER,
#	  PRIMARY KEY (author_id, pub_id),
#	  FOREIGN KEY (author_id) REFERENCES Authors(id) ON DELETE CASCADE,
#	  FOREIGN KEY (pub_id) REFERENCES Publications(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(authors_have_publications)
#
#	title_publications = '''
#	CREATE TABLE Title_Publications (
#                title_id INTEGER,
#                pub_id INTEGER,
#                PRIMARY KEY (title_id, pub_id),
#                FOREIGN KEY (title_id) REFERENCES Titles(id),
#                FOREIGN KEY (pub_id) REFERENCES Publications(id)
#        ) ENGINE=InnoDB;'''
#	createTable(title_publications)
#
#	webpages = '''
#	CREATE TABLE Webpages (
#	id INTEGER,
#	url VARCHAR(255),
#	PRIMARY KEY (id)
#	) ENGINE=InnoDB;'''
#	createTable(webpages)
#
#	authors_referenced_by = '''
#	CREATE TABLE authors_referenced_by (
#	webpage_id INTEGER,
#	author_id INTEGER,
#	PRIMARY KEY (webpage_id, author_id),
#	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
#	FOREIGN KEY (webpage_id) REFERENCES Authors(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(authors_referenced_by)
#
#	publishers_referenced_by = '''
#	CREATE TABLE publishers_referenced_by (
#	webpage_id INTEGER,
#	publisher_id INTEGER,
#	PRIMARY KEY (webpage_id, publisher_id),
#	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
#	FOREIGN KEY (publisher_id) REFERENCES Publishers(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(publishers_referenced_by)
#
#	titles_referenced_by = '''
#	CREATE TABLE titles_referenced_by (
#	webpage_id INTEGER,
#	title_id INTEGER,
#	PRIMARY KEY (webpage_id, title_id),
#	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
#	FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(titles_referenced_by)
#
#	title_series_referenced_by = '''
#	CREATE TABLE title_series_referenced_by (
#	webpage_id INTEGER,
#	title_series_id INTEGER,
#	PRIMARY KEY (webpage_id, title_series_id),
#	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
#	FOREIGN KEY (title_series_id) REFERENCES Title_Series(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(title_series_referenced_by)
#
#	publication_series_referenced_by = '''
#	CREATE TABLE publication_series_referenced_by (
#	webpage_id INTEGER,
#	publication_series_id INTEGER,
#	PRIMARY KEY (webpage_id, publication_series_id),
#	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
#	FOREIGN KEY (publication_series_id) REFERENCES Publication_Series(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(publication_series_referenced_by)
#
#	award_types_referenced_by = '''
#	CREATE TABLE award_types_referenced_by (
#	webpage_id INTEGER,
#	award_type_id INTEGER,
#	PRIMARY KEY (webpage_id, award_type_id),
#	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
#	FOREIGN KEY (award_type_id) REFERENCES Award_Types(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(award_types_referenced_by)
#
#	award_categories_referenced_by = '''
#	CREATE TABLE award_categories_referenced_by (
#	webpage_id INTEGER,
#	award_category_id INTEGER,
#	PRIMARY KEY (webpage_id, award_category_id),
#	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
#	FOREIGN KEY (award_category_id) REFERENCES Award_Categories(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(award_categories_referenced_by)

