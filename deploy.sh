#!/bin/sh


set -x
cd -P $(dirname $0)
if ! cd setup;then
   echo "Could not get the setup dir"
   exit 1
fi
   
echo Starting

mysqladmin create words
mysql words < words.sql

mysqladmin create rigveda
mysql rigveda < rigveda.sql


echo "Please copy cgi and pword in cgi-bin directory "


   

