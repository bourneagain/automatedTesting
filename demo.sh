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
echo "`cat demoProject.txt`"
echo ##
echo ##
echo "shall be run over 20 revisions and data collated in a CSV table for executed tests Vs Time."
echo ###
echo ###
echo "Please run this script within the script folder ####"



for i in `head -1 demoProject.txt`
do
PROJECT=`echo $i | awk -F, '{print $1}'`
BASEVERSION=`echo $i | awk -F, '{print $2}'`  
LOGDIR="/tmp/SE_DEMOLOGS/"
REVCOUNT=20
bash executeTest.sh "demo" $PROJECT $BASEVERSION $LOGDIR $REVCOUNT
done

