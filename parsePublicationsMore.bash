#!/bin/bash

PUBLICATION_FILE="publications_rem.csv"
TAB=$'\t' #http://stackoverflow.com/a/2623007/5432899
anyGroup=".\+${TAB}"
anyGroups1=""
for i in $(seq 1 9) #http://stackoverflow.com/a/169517/5432899
do
        anyGroups1="${anyGroups1}${anyGroup}"
done

anyGroups2=""
for i in $(seq 10 13)
        anyGroups2="${anyGroups2}${anyGroup}"
do

#add a columns between price number and currency value to make it easier to import Publications
currencies="$£"
regexp='\('"${anyGroups1}"'\)\('"${currencies}"'\)\([0-9]\+\)'"$anyGroups2"
#we invert 2 and 3 because of table and csv difference in ordering of fields
subst1='s/'"${regexp}"'/\1\3'"${TAB}"'\2\4/' 
sed -i.backup "${subst1}" "$PUBLICATION_FILE" #for lines with a price

subst2='s/\('"${anyGroups1}"'\)\N\('"${anyGroups2}"'\)/\1\N'"$TAB"'\N\2'
sed -i.backup2 "${subst2}" "$PUBLICATION_FILE" #for lines without a price


