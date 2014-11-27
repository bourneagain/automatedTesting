#!/bin/bash
################################
# Author : Shyam Rajendran     #
# Version : 1.0                #
################################
clear
echo "**************************************************************************************************************"
echo "#### DEMO FOR GATHERING TEST DATA ACROSS REVISIONS FOR BELOW PROJECTS [ THIS IS FOR WITHOUT EKSTAZI ] ######"
echo "### Each sample project listed below "
echo ##
echo ##
echo `cat projectList.txt | grep -v \# | egrep -v "^$"`
echo ##
echo ##
echo "shall be run over 20 revisions and data collated in a CSV table for executed tests Vs Time."
echo ###
echo ###
echo "Please run this script within the script folder ####"

##<CLONEURL>,<BASEVERSION>,<COMMAND>,<REPOTYPE>,<PROJECTNAME:CUSTOM>,<surefire_version>,<module>,<specific_ekstazi>,<patch>
IFS=$'\n'

for i in `cat projectList.txt | grep -v \# | egrep -v "^$"`
do
	CLONEURL=`echo $i | awk -F, '{print $1}'`
	BASEVERSION=`echo $i | awk -F, '{print $2}'`  
	TESTCMD=`echo $i | awk -F, '{print $3}'`  
	REPOFLAG=`echo $i | awk -F, '{print $4}'`  
	PROJECT=`echo $i | awk -F, '{print $5}'`  
	LOGDIR=""
	REVCOUNT=20
    surefire_version=`echo $i | awk -F, '{print $6}'`  
    modules="`echo $i | awk -F, '{print $7}'`"
    version=`echo $i | awk -F, '{print $8}'`  
    PATCH=`echo $i | awk -F, '{print $9}'`  
	DEMOFLAG=$1
	if [[ "$1" == "" ]] ; then 
		DEMOFLAG="demo"
	else
		DEMOFLAG="auto"
	fi

    bash -ux ./executeTestWithEkstazi.sh "${DEMOFLAG}" "${CLONEURL}" "${BASEVERSION}"  "${REVCOUNT}" "$LOGDIR" "${TESTCMD}" "${REPOFLAG}" "${PROJECT}" "${surefire_version}" "${modules}" "${version}" "${PATCH}"

done


#bash -ux ./executeTestWithEkstazi.sh auto http://svn.apache.org/repos/asf/logging/log4j/trunk r1344103 2 '' '' svn log4j 2.15 . 4.2.0 patch_log4j.sh





