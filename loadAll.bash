#!/bin/bash

source dbConfig.bash
source dbUtils.bash
source loadTuples.bash
source rmRet.sh

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

function keepOnly2LastOf3 {
	TAB=`echo -e "\t"`
	int=' *[0-9][0-9]* *'
	subst='s/^'"${int}${TAB}"'\('"${int}${TAB}${int}"'\)$/\1/g'
	sed -i.old "$subst" "$CSVLoc"/"$1"
}

clean
rmRetAllFiles #in rmRet.sh

#calling loadTuples
loadTuples "notes_rem.csv,Notes
	    languages_rem.csv,Languages 
	    authors_rem.csv,Authors_temp"
 
sqlConn '<' authors.sql #checked
loadTuples "titles_series_rem.csv,Title_Series_temp"
sqlConn '<' title_series.sql #checked

cd Python\ Parsing
python titles.py
cd -
rmRet CSV/titles.csv
loadTuples "titles_rem.csv,Titles_temp"

sqlConn  '<' titles.sql
sqlConn '<' title_is_translated_in.sql

keepOnly2LastOf3 reviews_rem.csv
loadTuples "reviews_rem.csv,title_is_reviewed_by
	    award_types_rem.csv,Award_Types_temp"
sqlConn '<' awardTypes.sql
loadTuples "award_categories_rem.csv,Award_Categories_temp"
sqlConn '<' awardCategories.sql

loadTuples "awards_rem.csv,Awards_temp"

sqlConn '<' awards.sql

#see http://stackoverflow.com/questions/4202564/how-to-insert-selected-columns-from-csv-file-to-mysql-using-load-data-infile  
#for following 2 lines of code



keepOnly2LastOf3 titles_awards_rem.csv

loadTuples "titles_awards_rem.csv,title_wins_award" 
#24 found in title_wins_award should have something around 25000

cd Python\ Parsing
python titles_tag.py
cd -
rmRet CSV/titles_tag.csv
loadTuples "tags_rem.csv,Tags titles_tag_rem.csv,title_has_tag publishers_rem.csv,Publishers_temp"
sqlConn '<' publishers.sql 
loadTuples "publications_series_rem.csv,Publication_Series_temp"
sqlConn '<' publication_series.sql

cd Python\ Parsing
python publications.py
cd -
rmRet CSV/publications.csv
loadTuples "publications_rem.csv,Publications_temp"
sqlConn '<' publications.sql

keepOnly2LastOf3 publications_authors_rem.csv
keepOnly2LastOf3 publications_content_rem.csv 
loadTuples "publications_authors_rem.csv,authors_have_publications
	    publications_content_rem.csv,Titles_published_as_Publications	
	    webpages_rem.csv,Webpages_temp" 

echo "
INSERT INTO Webpages(id, url)
SELECT id, url FROM Webpages_temp" > tmpSql.sql
sqlConn '<' tmpSql.sql

function loadDataInWebpageTable {
	# $1 can be authors or publishers or..
	newTableName="$1"_referenced_by 
	referenceID="$2"_id #$2 could be publisher or author or..
	referencedTable="$3"
	echo "
	INSERT INTO ${newTableName}(webpage_id, ${referenceID})
	SELECT wb.id, ${referenceID} 
	FROM Webpages_temp wb, ${referencedTable} refTable 
	WHERE ${referenceID} IS NOT NULL AND 
	refTable.id = wb.${referenceID};
	" > ${newTableName}.sql
	cat ${newTableName}.sql

	sqlConn '<' ${newTableName}.sql 
}

loadDataInWebpageTable authors author Authors
loadDataInWebpageTable publishers publisher Publishers
loadDataInWebpageTable titles title Titles
loadDataInWebpageTable title_series title_series Title_Series
loadDataInWebpageTable publication_series publication_series Publication_Series
loadDataInWebpageTable award_types award_type Award_Types
loadDataInWebpageTable award_categories award_category Award_Categories
