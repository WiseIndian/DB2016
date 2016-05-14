#!/bin/bash

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
regexp='\('"${anyGroups1}"'\)\([0-9]\+\)\(['"${currencies}"'\)'"$anyGroups2"
subst1='s/'"${regexp}"'/\1\2'"${TAB}"'\3\4/'
sed -i.backup "${subst1}" publications_rem.csv #for lines with a price

subst2='s/\('"${anyGroups1}"'\)\N\('"${anyGroups2}"'\)/\1\N'"$TAB"'\N\2'
sed -i.backup2 "${subst2}" publications_rem.csv #for lines without a price


