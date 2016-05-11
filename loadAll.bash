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
function loadTuples { 
	OLDIFS=$IFS
	tuples="$@" #load arguments of loadTuples into tuples

	if [ -f sqlLoadFile.sql ]; then
		rm sqlLoadFile.sql
	fi

	for t in $tuples; do 
		IFS=","
		set -- $t  
		#set $1, $2 ... to all comma separated values
		temp1="$loadCommand1""$1"
		temp2="$loadCommand2""$2""$loadCommand3"
		sqlCmd="$temp1""$temp2"
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
loadTuples "notes_rem.csv,Notes languages_rem.csv,Languages authors_rem.csv,Authors_temp"
 
sqlConn " < authors.sql" #checked

loadTuples "title_series_rem.csv, Title_Series_temp"
sqlConn " < title_series.sql" #checked

loadTuples "titles_rem.csv,Titles_temp"
sqlConn  " < titles.sql"
#
#	titles = '''
#	CREATE TABLE Titles (
#	  id INTEGER,
#	  title VARCHAR(255) NOT NULL,
#	  synopsis TEXT,
#	  note TEXT,
#	  story_len ENUM('nv', 'ss', 'jvn', 'nvz', 'sf'),
#	  type ENUM('ANTHOLOGY', 'BACKCOVERART', 'COLLECTION', 'COVERART', 'INTERIORART',
#		  'EDITOR', 'ESSAY', 'INTERVIEW', 'NOVEL', 'NONFICTION', 'OMNIBUS', 'POEM',
#		  'REVIEW', 'SERIAL', 'SHORTFICTION', 'CHAPBOOK'),
#	  parent INTEGER,
#	  language_id INTEGER,
#	  title_graphic BOOLEAN,
#	  PRIMARY KEY (id),
#	  FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE SET NULL
#	) ENGINE=InnoDB;'''
#	createTable(titles)
#
#	title_is_translated_in = '''
#	CREATE TABLE title_is_translated_in (
#	  title_id  INTEGER,
#	  trans_title_id INTEGER,
#	  language_id INTEGER NOT NULL,
#	  translator VARCHAR(64),
#	  PRIMARY KEY (trans_title_id),
#	  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
#	  FOREIGN KEY (trans_title_id) REFERENCES Titles(id) ON DELETE CASCADE,
#	  FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(title_is_translated_in);
#
#
#	title_is_reviewed_by = '''
#	CREATE TABLE title_is_reviewed_by (
#	title_id  INTEGER,
#	review_title_id INTEGER,
#	PRIMARY KEY (title_id, review_title_id),
#	FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
#	FOREIGN KEY (review_title_id) REFERENCES Titles(id) ON DELETE CASCADE,
#	CHECK (title_id != review_title_id)
#	) ENGINE=InnoDB;'''
#	createTable(title_is_reviewed_by)
#
#	title_is_part_of_Title_Series = '''
#	CREATE TABLE title_is_part_of_Title_Series (
#	title_id  INTEGER,
#	series_id INTEGER NOT NULL,
#	series_number INTEGER,
#	PRIMARY KEY (title_id),
#	FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
#	FOREIGN KEY (series_id) REFERENCES Title_Series(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(title_is_part_of_Title_Series)
#
#
#	award_types_temp = '''
#	CREATE TABLE Award_Types_temp (
#	  id INTEGER,
#	  code VARCHAR(5),
#	  name VARCHAR(255),
#	  note_id INTEGER,
#	  awarded_by VARCHAR(255),
#	  awarded_for VARCHAR(255),
#	  short_name VARCHAR(255),
#	  is_poll BOOLEAN,
#	  non_genre BOOLEAN,
#	  PRIMARY KEY (id),
#	  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
#	  CHECK (name IS NOT NULL OR code IS NOT NULL)
#	) ENGINE=InnoDB;'''
#	createTable(award_types_temp)
#
#	award_types = '''
#	CREATE TABLE Award_Types (
#	  id INTEGER,
#	  code VARCHAR(5),
#	  name VARCHAR(255),
#	  note TEXT,
#	  awarded_by VARCHAR(255),
#	  awarded_for VARCHAR(255),
#	  short_name VARCHAR(255),
#	  is_poll BOOLEAN,
#	  non_genre BOOLEAN,
#	  PRIMARY KEY (id),
#	  CHECK (name IS NOT NULL OR code IS NOT NULL)
#	) ENGINE=InnoDB;'''
#	createTable(award_types)
#
#	award_categories_temp = '''
#	CREATE TABLE Award_Categories_temp (
#	  id INTEGER,
#	  name VARCHAR(255),
#	  type_id INTEGER,
#	  category_order INTEGER,
#	  note_id INTEGER,
#	  PRIMARY KEY (id, type_id),
#	  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
#	  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(award_categories_temp)
#
#	award_categories = '''
#	CREATE TABLE Award_Categories (
#	  id INTEGER,
#	  name VARCHAR(255),
#	  type_id INTEGER,
#	  category_order INTEGER,
#	  /* position INTEGER, TODO what is position, is this award category order?*/
#	  note TEXT,
#	  PRIMARY KEY (id, type_id),
#	  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(award_categories);
#
#
#	awards_temp = '''
#	CREATE TABLE Awards_temp (
#	  id INTEGER,
#	  title VARCHAR(255),
#	  aw_date DATE,
#	  type_id INTEGER,
#	  category_id INTEGER,
#	  note_id INTEGER,
#	  PRIMARY KEY (id),
#	  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
#	  FOREIGN KEY (category_id) REFERENCES Award_Categories(id) ON DELETE SET NULL,
#	  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE SET NULL
#	) ENGINE=InnoDB;'''
#	createTable(awards_temp)
#
#	awards = '''
#	CREATE TABLE Awards (
#	  id INTEGER,
#	  title VARCHAR(255),
#	  aw_date DATE,
#	  type_id INTEGER,
#	  category_id INTEGER,
#	  note_id TEXT,
#	  PRIMARY KEY (id),
#	  FOREIGN KEY (category_id) REFERENCES Award_Categories(id) ON DELETE SET NULL,
#	  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE SET NULL
#	) ENGINE=InnoDB;'''
#	createTable(awards)
#
#	title_wins_award = '''
#	CREATE TABLE title_wins_award (
#	award_id  INTEGER,
#	title_id INTEGER,
#	PRIMARY KEY (award_id, title_id),
#	FOREIGN KEY (award_id) REFERENCES Awards(id) ON DELETE CASCADE,
#	FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE
#	) ENGINE=InnoDB;'''
#	createTable(title_wins_award)
#
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
