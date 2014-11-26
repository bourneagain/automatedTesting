#!/bin/bash -u
################################
# Author : Shyam Rajendran     #
# Version : 1.0                #
# About : This script is used to partially automate the effort of changing pom files per revision for running tests with Ekstazi. 
#    For ekstazi, run tests on decreasing order of SHA i.e. from 20 to 1
#    Add git clean -fxd and copy .ekstazi folder before executing test for a revision. 
#    Merge TESTDIR and COMMAND in script arguments and ask user to write the commands directly ( optional or try to have different input fields ) 
#    if same POM remains same across multiple revisions, don’t prompt vimdiff for each but instead use the manual diff on earlier pom for subsequent revisions as well. Save the modified pom per revision for subsequent use in svn.
#    Change SVN permissions for executable scripts 
#        Ex  - SVN prop:set executable demo.sh
#    Check to run  mvm install -DslipTests for projects similar to guava- if you get snapshot error
################################

(
#source functions
source includeFunctions.sh

SCRIPTDIR=`pwd`

AUTOFLAG=$1
#GET ALL INPUTS
getInput "$@" 
#SET GLOBAL VARIABLES AS PER SPECIFIC TEST CONDITION
if [[ ${TESTCMD} == "" ]]
then
	TESTCMD="mvn test"
fi
if [[ ${LOGDIR} == "" ]] 
then
	LOGDIR=${SCRIPTDIR}"/../logs/"
fi
if [[ ${REVCOUNT} == "" ]] 
then
 	REVCOUNT=1
fi

RESULTSDIR=${LOGDIR}
REPODIR=${LOGDIR}"/repoDir/"
LOGDIR=${LOGDIR}"/wEkstazi/"
mkdir -p ${LOGDIR} 2>&1 > /dev/null
mkdir -p ${REPODIR} 2>&1 > /dev/null
EKSTAZIBACKUPFOLDER="/tmp/${PROJECT}"
LOGNAME=$LOGDIR"/"${PROJECT}"_withEkstazi.log"



if [[ ! "$AUTOFLAG" == "auto" ]]; then
	checkREFDir
fi





#BACKUP EKSTAZI DIR
removeEkstaziDir ${EKSTAZIBACKUPFOLDER}

#CLONE REPO : IF NOT CREATED ALREADY
checkAndCloneRepo

#MOVE HEAD TO BASE VERSION
echo "ABOUT TO CHECKOUT"
#read a
cloneCheckout ${REPOFLAG} ${BASEVERSION}

echo "pwd : `pwd`"
PPWD=`pwd`
#read a
#INSTALL SNAPSHOTS
#installSnapShots

#
##installing old
#installEKTAZI "3.4.2"
##installing new as well
#installEKTAZI "4.1.0"
#coloredEcho "EKSTAZI INSTALLED"
#
#read a
#GET LAST N COMMITS TO GATHER DATA
getLastNCommits ${REPOFLAG}
#read a
echo $LASTNCOMMITS
IFS=$'\n'
coloredEcho "#####"
coloredEcho "#####"
coloredEcho "You will be presented with ${REVCOUNT} files to modify"
coloredEcho "Please use \":wqa!\" to save the file and quit after modification or \":xa!\" to quit without saving. Press to continue"
coloredEcho "#####"

> ${LOGNAME}

saveReferencePOMS ${AUTOFLAG}
echo "DONE WITH POM CHANGES FOR ALL THE ${REVCOUNT} VERSIONS"
coloredEcho "STARTING TO EXECUTE WITH POM CHANGES FOR EKSTAZI. Press enter to continue"

#read a



#read a
#START EXECUTION 

runWithEkstazi ${PPWD} ${AUTOFLAG}


cd $SCRIPTDIR
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
bash  collateResults.sh ${RESULTSDIR} ${SCRIPTDIR}
)
