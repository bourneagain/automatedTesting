#!/bin/bash
################################
# Author : Shyam Rajendran     #
# Version : 1.0                #
################################


function getInput() {

if [ "$1" == "demo" ] 
then
	PROJECT=$2
	BASEVERSION=$3
	LOGDIR=$4
	REVCOUNT=$5
else


		echo "**************************************************************************************************************"
		echo ###
		echo "ABOUT"
		echo ###
		echo "The script , given a clone url, and base revision to test, will clone the project and execute maven test for multiple revisions and output a collated table of executed tests, execution time etc as a csv" 
		echo "** Default branch is master"
		echo "[The scipt can be latter modified to automatically execute list of projects across multiple revisions from a file input and chart the CSV]"
		echo ###
#echo "EXAMPLE : ./getProjects.sh https://github.com/apache/commons-math.git <BASEVERSION> <LOGDIRTOSAVE> [DEFAULT is MASTER BRANCH]"
		echo "**************************************************************************************************************"
		echo ###
		echo "Please input the script argurments "
		echo ###
		echo "** Please note this input shall be replaced with commandline args when automation is completed "
		echo "** Interactive input is only for demo"
		echo #
		echo -e "CLONE URL : This is the git/svn project repo url  [ currently supported for git ]				: \c"
		read PROJECT 
		echo -e "BASE COMMIT VERSION : This is the base commit revision number to start test execution 				: \c" 
		read BASEVERSION
		echo -e "NUMBER OF REVISION TO TEST											: \c" 
		read REVCOUNT 
		echo -e "LOGDIR: Logfile to save execution details [ note single log file for all execution across revisions ]		: \c" 
		read LOGDIR

# the interactive code can be replaced with command line with full automation is available. 
# PROJECT URL SAVED 
fi
		echo "**************************************************************************************************************"
		echo #
		echo "******"
		echo "INPUTS"
		echo "******"
		echo #
		echo "PROJECT  URL      : $PROJECT"
		echo "BASEVERSION       : $BASEVERSION"
		echo "# of Revs to test : $REVCOUNT"
		echo "LOGDIR            : $LOGDIR"
		echo ###
		echo ###
		echo ###
		echo "FINAL LOGS AFTER EXECUTION WILL BE AVAILABLE UNDER $LOGDIR/woEkstazi/ directory"
		echo #
		echo #
		echo "Press enter to continue after verification input"
		read a

clear
}

PPWD=`pwd`


getInput "$@" 
# FETCH GIT REPO DIR FROM URL
DIRPATH=`echo $PROJECT |  sed 's,/$,,g' | awk -F/ '{print $NF}' | awk -F'.' '{print $1}'`


# CHECK TO SEE IF THE GIT DIR ALREADY EXISTS
skip=0
if [ -d $DIRPATH ] 
then
echo "  PROJECT PATH $DIRPATH ALREADY EXISTS"
skip=1
fi

mkdir -p $LOGDIR"/woEkstazi/" 2>&1 > /dev/null
pwd
echo ">>>>>> MKDIR COMPLETED $LOGDIR/woEkstazi/"
CHARTDIR=$LOGDIR
LOGDIR=$LOGDIR"/woEkstazi/"
if [ ! -d $LOGDIR ] 
then
echo "ERROR CREATING DIRECTORY $LOGDIR , PLEASE CHECK FOR PERMISSION"
exit 
fi

#https://github.com/google/closure-compiler.git
LOGPATH=$LOGDIR"/"${DIRPATH}"_woEkstazi.log"
echo ">>>>>>>>>>>>>>>>>>> LOG PATH IS " $LOGPATH
if [[ $skip == 0 ]] 
then
# START CLONING THE PROJECT 
	echo "  ISSUING GIT CLONE COMMAND : git clone $PROJECT" >> $LOGPATH
	git clone $PROJECT
	cd `ls -ltr | awk '{print $NF}' | tail -1`
	ls
else
	cd $DIRPATH
	ls
fi
# CHECKOUT TO BASE REVISION 
if [[ ! -z "$BASEVERSION" ]]
then
git checkout $BASEVERSION
fi

# FETCH  MOST RECENT COMMIT INFORMATION
echo "  FETCHING COMMIT INFORMATION FOR THE RECENT $REVCOUNT"
LASTNCOMMITS=`git log -n $REVCOUNT --oneline | awk '{print $1}'`


# RUN TARGET TEST FOR EACH COMMIT
echo "  RUNNING TEST FOR THE LAST $REVCOUNT FETCH COMMITS"
IFS=$'\n'
for i in $LASTNCOMMITS
do
# RUN TEST FOR EACH COMMIT
	echo "pwd is `pwd`"
	echo ">>>>>>>>>>>>>>>>>>>> BEGIN COMMIT : $i : ">> $LOGPATH
	echo `date` >> $LOGPATH
	mvn test | tee -a $LOGPATH
	echo ">>>>>>>>>>>>>>>>>>>> END OF EXECUTION FOR : $i ">> $LOGPATH
done
clear
cd $PPWD

echo #
echo #
echo "Execution completed"
echo #
echo #
echo "**********************************"
echo "STARTING TO COLLATE DATA FOR TABLE"
echo "**********************************"
echo #
echo #
bash collateResults.sh $CHARTDIR
