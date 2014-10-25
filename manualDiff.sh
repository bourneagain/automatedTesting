#!/bin/bash
#########################################################
# Author : Shyam Rajendran                            #
# Version : 1.0                                       #
# About : Script will help manually change pom easily #
#########################################################
clear



if [[ $# -lt 2 ]]
then
echo "Please input <list> containing list of pom files to modify  and <REFDIR> the directory which contains the modified pom files"
echo "EXAMPLE : ./manualDiff.sh <list> <REFDIR>" 
exit
fi

#FILELIST CONTAING THE LIST OF POM FILES TO MODIFY
FILELIST=$1

#DIR WHERE REFERENCE POMS ARE SAVED : FOR EKSTAZI 
REFDIR=$2

#use xa! to quit without saving and 
#use wqa! to quit with saving
for i in `cat $FILELIST`
do 
	vimdiff $REFDIR/${i} ${i}
done
