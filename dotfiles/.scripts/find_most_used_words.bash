#!/bin/bash

text=$1

#echo "Unique Full Names:"
#cat $1 | tr "[:punct:]" "\n" | sed "s/^\s\+//g" | sort -i | uniq -c | sort -nr
#
#echo "Unique First and Last Names:"
#cat $1 | tr "[:punct:]" "\n" | sed "s/^\s\+//g" | sed "s/ /\n/g" | sort -i | uniq -c | sort -nr

cat $1 | grep -oi "[a-z]\+" | sort | uniq -c | sort -nr


#| sed 's/\,/\n/g' | sed "s/\.//g" | sed "s/^\s\+//g" | sed "s/ /\n/g" | sort | sed "s/^\s\+//g" | uniq -i -c | less | sort | sort -nr | grep -i "[a-z]"

