#!/bin/bash

# this script is used to invert the columns of currencies and prices in csv files
# there are 13 columns in publications.csv we want that 
# $5.43 
# £23.12 
# ..
# gets transformed into:
# $\t5.42
# £\t32.12
# ...         that's what this script is for

sed -n '1,12p;' CSV/publications.csv > tmp
cat tmp > tmpPub.csv
PUBLICATION_FILE="tmpPub.csv" #TODO CHANGE THAT!!
TAB=`echo -e "\t"` #http://stackoverflow.com/a/2623007/5432899
anyButTab="[^${TAB}]"
anyGroup="${anyButTab}${anyButTab}"'*'"${TAB}" #anything one or more time followed by a tab
anyGroups1=""
for i in $(seq 1 9) #http://stackoverflow.com/a/169517/5432899
do
        anyGroups1="${anyGroups1}${anyGroup}"
done

anyGroups2=""
for i in $(seq 11 12)
do
        anyGroups2="${anyGroups2}${anyGroup}"
done
anyGroups2="${anyGroups2}${anyButTab}${anyButTab}"'*'

#add a columns between price number and currency value to make it easier to import Publications
int='[0-9][0-9]*'
decimalNb="${int}"'\.'"${int}"
currencies='$£' 

regexLeft='\('"${anyGroups1}"'\) *\(['"${currencies}"']\)'
#then at the end
regexRight='\('"${TAB}${anyGroups2}"'\)'

function substituteWherePrice {
	reg="${regexLeft}"'\('"${1}"'\) *'"${regexRight}"
	subst='s/'"${reg}"'/\1\2'"${TAB}"'\3\4/g'
	echo "${subst}"
	sed -i.backup "${subst}" "${PUBLICATION_FILE}" #for lines with a price t
}

#we invert 2 and 3 because of table and csv difference in ordering of fields
substituteWherePrice "${int}"
substituteWherePrice "${decimalNb}"

#we have to use 3 seds because of when \N is present in price column we want 2 \N
#and because of course there is the normal case where there is a price(Int and decimal price). 
#subst2='s/\('"${anyGroups1}"'\) *\N *'"${TAB}"'\('"${anyGroups2}"'\)/\1\N'"${TAB}"'\N'"${TAB}"'\2/g'
#echo "${subst2}"
#sed -i.backup2 "${subst2}" "${PUBLICATION_FILE}" #for lines without a price


