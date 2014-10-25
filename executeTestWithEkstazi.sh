#!/bin/bash
################################
# Author : Shyam Rajendran     #
# Version : 1.0                #
# About : This script is used to partially automate the effort of changing pom files per revision for running tests with Ekstazi. 
################################

PPWD=`pwd`
function createClone() {
# to be added when clone creation in Ekstazi is completed.
# usually run without Ektazi first and then this.
echo #
}
function getInputs() {
clear

echo "**************************************************************************************************************"
echo ###
echo "PRECONDITION"
echo ###
echo "The script assumes you already have a repo ( GIT ) cloned and know the POM changes to be done for Ekstazi."
echo "Kindly save the reference POM ( modified for some POM version into a directory retaining the clone directory structure )"
echo "Example for running Ekstazi on Guava,"
echo "POM needs to be changed only under guava-tests/pom.xml : so save it under a directory like"
echo "			REFDIR/guava-tests/pom.xml and feed the REFDIR to the script when it is requested for during the execution"

echo "**************************************************************************************************************"
echo ###
echo "Please input the script argurments "
echo ###
echo "** Please note this input shall be replaced with commandline args when automation is completed "
echo "** Interactive input is only for demo"
echo #
echo -e "CLONEPATH : This is the path to git/svn repo [ currently supported for git ] 					: \c"
read CLONEPATH
echo -e "BASE COMMIT VERSION : This is the base commit revision number to start Ekstzi 					: \c" 
read BASEVERSION
echo -e "ABSOLUTEPATH TO REFERNCE DIRECTORY: holding modified files. If you have not created reference dir, please quit : \c" 
read REFDIR
echo -e "Number of commits to execute tests on 										: \c"
read COMMITNUMBER
echo -e "TESTFOLDER: when tests are run from within a specific module, enter the module path with reference to clonedir	: \c"
read TESTFOLDER
echo -e "LOGDIR: Log directory to save execution details 								: \c" 
read LOGDIR

# the interactive code can be replaced with command line with full automation is available. 
#CLONEPATH=$1
#BASEVERSION=$2
#REFDIR=$3
#COMMITNUMBER=$4
#TESTFOLDER=$5
#LOGDIR=$6
echo "**************************************************************************************************************"
echo #
echo #
echo "******"
echo "INPUTS"
echo "******"
echo #
echo "CLONEPATH         : $CLONEPATH"
echo "BASEVERSION       : $BASEVERSION"
echo "REFDIR            : $REFDIR"
echo "Number of Rev     : $COMMITNUMBER"
echo "TESTFOLDER        : $TESTFOLDER"
echo "LOGDIR            : $LOGDIR"
echo #
echo #
echo "Press enter to continue after verification input"
read a
}




function installEKTAZI() {
version=3.4.2
url="mir.cs.illinois.edu/gliga/projects/ekstazi/release/"
if [ ! -e org.ekstazi.core-${version}.jar ]; then wget "${url}"org.ekstazi.core-${version}.jar; fi
if [ ! -e org.ekstazi.ant-${version}.jar ]; then wget "${url}"org.ekstazi.ant-${version}.jar; fi
if [ ! -e ekstazi-maven-plugin-${version}.jar ]; then wget "${url}"ekstazi-maven-plugin-${version}.jar; fi


mvn install:install-file -Dfile=org.ekstazi.core-${version}.jar -DgroupId=org.ekstazi -DartifactId=org.ekstazi.core -Dversion=${version} -Dpackaging=jar -DlocalRepositoryPath=$HOME/.m2/repository/
mvn install:install-file -Dfile=ekstazi-maven-plugin-${version}.jar -DgroupId=org.ekstazi -DartifactId=ekstazi-maven-plugin -Dversion=${version} -Dpackaging=jar -DlocalRepositoryPath=$HOME/.m2/repository/
}

#if [[ $# -lt 1 ]]
#then
#echo "About : A script to save pom's to be modified of different revisions. The modified pom's can be copied when the revision is checked out for Ekstazi tests"
#echo "Please input project clone path "
#echo "EXAMPLE <SCRIPT> CLONEPATH=\$1 BASEVERSION=\$2 FULL PATH OF REFDIR=\$3"
#echo "bash savePom.sh project/guava-libraries f2a818b /Users/sam/cs527/project/guavaPomReference "
#exit
#fi

getInputs
mkdir -p $LOGDIR"/wEkstazi/" 2>&1 > /dev/null
CHARTDIR=$LOGDIR
LOGDIR=$LOGDIR"/wEkstazi/"

PROJECTDIR=`echo $CLONEPATH | sed 's,/$,,g' | awk -F"/" '{print $NF}'`
#LOGPATH=$LOGDIR"/"$PROJECTDIR.log
LOGPATH=$LOGDIR"/"${PROJECTDIR}"_withEkstazi.log"
echo ###
echo ###
echo ###
echo ###
echo ###
echo ###
echo "INSTALLING EKSTAZI"
installEKTAZI
echo ###
echo ###
echo "EKSTAZI INSTALLED"
echo ###
echo ###

pwd=`pwd`
# CHECKOUT TO BASE REVISION 
if [ -d $CLONEPATH ] 
then
cd $CLONEPATH
fi

if [[ ! -z "$BASEVERSION" ]]
then
git checkout $BASEVERSION
fi

# FETCH 20 MOST RECENT COMMIT INFORMATION
echo ">>>>>>>>>>>>>>>>>>>> FETCHING COMMIT INFORMATION FOR THE RECENT $COMMITNUMBER COMMITS"
#LASTNCOMMITS=`git log -n 100 --oneline | awk '{print $1}' | tail -2 |  tee /tmp/LASTNCOMMITS`
LASTNCOMMITS=`git log -n $COMMITNUMBER --oneline | awk '{print $1}' |  tee /tmp/LASTNCOMMITS`

diffpath=""
# RUN TARGET TEST FOR EACH COMMIT
IFS=$'\n'

echo ####
echo ####
echo ####
echo "#####"
echo "#####"
echo "You will be presented with $COMMITNUMBER files to modify"
echo "Please use \":wqa!\" to save the file and quit after modification or \":xa!\" to quit without saving. Press to continue"
echo "#####"
echo "#####"
read a

for i in $LASTNCOMMITS
do
	for file in `find $REFDIR -type f -name "*pom*"`
	do
		echo "FILE IS " $file
		echo $REFDIR
		dirStructure=`echo $file | sed "s,^.*$REFDIR/,,g" | xargs dirname`
		fileName=`echo $file | sed "s,^.*$REFDIR/,,g" | xargs basename`
		echo "DIRSTRUCTURE" $dirStructure
		echo "FILENAME"  $fileName
		mkdir -p $pwd"/"$i"/"$dirStructure
		echo " >>>>>>>>>>>>>>> copying"
		cp $dirStructure"/"$fileName $pwd"/"$i"/"$dirStructure"/$fileName"
		vimdiff $file $pwd"/"$i"/"$dirStructure"/"$fileName
	done
done

clear
echo ###
echo "DONE WITH POM CHANGES FOR ALL THE $COMMITNUMBER VERSIONS"
echo ###
echo ###

echo "STARTING TO EXECUTE WITH POM CHANGES FOR EKSTAZI. Press enter to continue"
read a
for i in $LASTNCOMMITS
do
# RUN TEST FOR EACH COMMIT
	echo ">>>>>>>>>>>>>>>>>>>> BEGIN COMMIT : $i : ">> $LOGPATH
	echo `date` >> $LOGPATH

	for file in `find $REFDIR -type f -name "*pom*"`
	do
		dirStructure=`echo $file | sed "s,^.*$REFDIR/,,g" | xargs dirname`
		fileName=`echo $file | sed "s,^.*$REFDIR/,,g" | xargs basename`
		echo "DIRSTRUCTURE" $dirStructure
		echo "FILENAME"  $fileName
		mkdir -p $pwd"/"$i"/"$dirStructure
		echo " >>>>>>>>>>>>>>> copying"
		#echo "cp $pwd\"/\"$i\"/\"$dirStructure\"/$fileName\" $CLONEPATH"/"$dirStructure\"/\"$fileName"
		cp $pwd"/"$i"/"$dirStructure"/"$fileName $CLONEPATH"/"$dirStructure"/"$fileName
	done
	cd $TESTFOLDER
	echo "RUNNING mvn test inside $TESTFOLDER"
	mvn test | tee -a $LOGPATH
	cd .. 
	echo ">>>>>>>>>>>>>>>>>>>> END OF EXECUTION FOR $i ">> $LOGPATH


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
bash  collateResults.sh $CHARTDIR

