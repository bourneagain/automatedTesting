#!/bin/bash
################################
# Author : Shyam Rajendran     #
# Version : 1.0                #
################################

#source functions.
source includeFunctions.sh


SCRIPTDIR=`pwd`
getInput "$@" 
if [[ $LOGDIR == "" ]] 
then
	LOGDIR=$SCRIPTDIR"/../logs/"
fi
if [[ $REVCOUNT == "" ]] 
then
 	REVCOUNT=1
fi
if [[ ${TESTCMD} == "" ]]
then
	TESTCMD="mvn test"
fi

#GLOBAL VARIABLES
RESULTSDIR=$LOGDIR
REPODIR=$LOGDIR"/repoDir/"
LOGDIR=$LOGDIR"/woEkstazi/"
LOGNAME=$LOGDIR"/"${PROJECT}"_withoutEkstazi.log"

#CREATING LOG AND REPO DIR 
mkdir -p $LOGDIR 2>&1 > /dev/null
mkdir -p $REPODIR 2>&1 > /dev/null




if [ -d $REPODIR/$PROJECT ] 
then
    coloredEcho "PROJECT PATH $REPODIR/$PROJECT ALREADY EXISTS"
    cd $REPODIR/$PROJECT
	coloredEcho "LISTING FILES IN THE CLONE..."
    ls
else
	# START CLONING THE PROJECT 
	cd $REPODIR
	coloredEcho "  ISSUING CLONE COMMAND " >> $LOGNAME
	pullClone ${REPOFLAG} ${2}
	cd $REPODIR/$PROJECT
	ls
fi


coloredEcho " MOVING HEAD TO BASE COMMIT"
cloneCheckout ${REPOFLAG} ${BASEVERSION}
#INSTALL SNAPSHOTS
installSnapShots

#enter the clone
cd ${PROJECT}
# RUN TARGET TEST FOR EACH COMMIT
coloredEcho "  RUNNING TEST FOR THE LAST $REVCOUNT FETCH COMMITS"

> ${LOGNAME}
getLastNCommits ${REPOFLAG}
#run iterative test
runTest

#clear
cd $SCRIPTDIR
coloredEcho "Execution completed"
coloredEcho "**********************************"
coloredEcho "STARTING TO COLLATE DATA FOR TABLE"
coloredEcho "**********************************"
bash collateResults.sh $RESULTSDIR $SCRIPTDIR

