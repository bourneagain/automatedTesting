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
echo "`cat projectList.txt`"
echo ##
echo ##
echo "shall be run over 20 revisions and data collated in a CSV table for executed tests Vs Time."
echo ###
echo ###
echo "Please run this script within the script folder ####"



IFS=$'\n'
for i in `cat projectList.txt | grep -v \#`
do
		CLONEURL=`echo $i | awk -F, '{print $1}'`
		BASEVERSION=`echo $i | awk -F, '{print $2}'`  
		TESTCMD=`echo $i | awk -F, '{print $3}'`  
		REPOFLAG=`echo $i | awk -F, '{print $4}'`  
		PROJECT=`echo $i | awk -F, '{print $5}'`  
		LOGDIR=""
		REVCOUNT=20
		bash -ux executeTestWithEkstazi.sh "demo" $CLONEURL $BASEVERSION  $REVCOUNT "$LOGDIR" "${TESTCMD}" ${REPOFLAG} ${PROJECT}
done

