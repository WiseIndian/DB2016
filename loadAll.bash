#!/bin/bash

source dbConfig.bash
source dbUtils.bash
source loadTuples.bash

#you have to execute this script in base of repo i.e. from DB2016
#and that because the load*.sql files use paths relative to the current directory!


#used to connect to the database and execute some sql script

function clean {
	lsOutput=`ls $csvLocation/*_rem.csv` 
	#testing if $lsOutput is an empty string`man test` for more info on this if
	if [ -n ${lsOutput:0:20} ]; then #print 21 first characters of $lsOutput and see if its empty
		rm "$csvLocation"/*_rem.csv #we want to start with a fresh output from rmRet.sh
	fi
}


#call this function like:
#loadTuples "csv1.csv,Table1 csv2.csv,Table2" "<additional-sql-code-to-append-to-loadCommand3>"
#tuples is "csv1.csv,...,Table2" 
#and appendable is "<additional-sql-code-to-append-to-loadCommand3>"
#loadTuples "titles_awards_rem.csv,title_wins_award" "$csvColumnsTitleAwards"

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
	sqlConn '<' sqlDeleteFile 
}

clean
sh rmRet.sh #delete ^M and other bullshit carriage return \r...

#calling loadTuples
loadTuples "notes_rem.csv,Notes
	    languages_rem.csv,Languages 
	    authors_rem.csv,Authors_temp"
 
sqlConn '<' authors.sql #checked

loadTuples "titles_series_rem.csv,Title_Series_temp"
sqlConn '<' title_series.sql #checked

loadTuples "titles_rem.csv,Titles_temp"
sqlConn  '<' titles.sql
sqlConn '<' title_is_translated_in.sql
loadTuples "reviews_rem.csv,title_is_reviewed_by
	    award_types_rem.csv,Award_Types_temp"
sqlConn '<' awardTypes.sql
loadTuples "award_categories_rem.csv,Award_Categories_temp"
sqlConn '<' awardCategories.sql

cd Python\ Parsing
python awards.py
cd -
loadTuples "awardsCLEAN.csv,Awards_temp"
#should have 37655 entries in awards only have 60 .. which could be linked with
# the fact that title_wins_award doesn't have many entries

sqlConn '<' awards.sql

#see http://stackoverflow.com/questions/4202564/how-to-insert-selected-columns-from-csv-file-to-mysql-using-load-data-infile  
#for following 2 lines of code

function keepOnly2LastOf3 {
	TAB=`echo -e "\t"`
	int=' *[0-9][0-9]* *'
	subst='s/^'"${int}${TAB}"'\('"${int}${TAB}${int}"'\)$/\1/g'
	sed -i.old "$subst" "$CSVLoc"/"$1"
}

keepOnly2LastOf3 titles_awards_rem.csv

loadTuples "titles_awards_rem.csv,title_wins_award" 
#24 found in title_wins_award should have something around 25000

cd Python\ Parsing
python titles_tag.py
cd -
loadTuples "tags_rem.csv,Tags titles_tagCLEAN.csv,title_has_tag publishers_rem.csv,Publishers_temp"
sqlConn '<' publishers.sql 
loadTuples "publications_series_rem.csv,Publication_Series_temp"
sqlConn '<' publication_series.sql

cd Python\ Parsing
python publications.py
cd -
loadTuples "publicationsCLEAN.csv,Publications_temp"
sqlConn '<' publications.sql

keepOnly2LastOf3 publications_authors_rem.csv
loadTuples "publications_authors_rem.csv,authors_have_publications" 
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

