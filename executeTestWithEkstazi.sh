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
<<<<<<< .mine

(
#source functions
source includeFunctions.sh

SCRIPTDIR=`pwd`

=======
>>>>>>> .r2465
<<<<<<< .mine
#GET ALL INPUTS
getInput "$@" 
=======
PPWD=`pwd`
backupEkstazi() {
for ekstaziFolder in `find ${REPODIR}/${PROJECT} -type d -name ".ekstazi"`
do
	#rm -rf /tmp/{PROJECT}/ 2>&1 > /dev/null 
	#copy part
	savePath=`echo ${ekstaziFolder} | sed "s,^.*${PROJECT}/,,g" | sed 's,^/,,g'`
	mkdir -p /tmp/${PROJECT}/${savePath}
	echo "BACKING UP EKSTAZI >>>>>>>>>>>>>>>>>>>>>>>>  mv ${ekstaziFolder} /tmp/${PROJECT}/${savePath}"
	mv ${ekstaziFolder}/* /tmp/${PROJECT}/${savePath}
done
}
>>>>>>> .r2465

<<<<<<< .mine
=======
restoreEkstazi() {
PN=${PROJECT}
if [ -d /tmp/${PROJECT} ] 
then
  for backUpFolder in `find /tmp/${PN}/ -type d -name ".ekstazi"`
  do
	savePath=`echo ${backUpFolder}| sed "s,^.*${PROJECT}/,,g" | sed 's,^/,,g'`
    echo ${savePath}
	mkdir -p ${REPODIR}"/"${PROJECT}/${savePath}
    echo "mv ${backUpFolder}/* ${PROJECT}/${savePath}"
    mv ${backUpFolder}/* ${REPODIR}/${PROJECT}/${savePath}
  done
fi
}
>>>>>>> .r2465

<<<<<<< .mine
#SET GLOBAL VARIABLES AS PER SPECIFIC TEST CONDITION
=======
getInput() {
if [ "${1}" == "demo" ] 
then
    CLONEURL=${2}
    BASEVERSION=${3}
    REVCOUNT=${4} 
    LOGDIR=""
    TESTCMD=${5}
    REFDIR=""

#    CLONEURL=https://github.com/JodaOrg/joda-time.git
#    BASEVERSION=f36072e
#    REVCOUNT=3
#    LOGDIR=""
#    TESTCMD=""


else
	#clear
    echo "**************************************************************************************************************"
    echo ###
    echo "PRECONDITION"
    echo ###
    echo "Kindly save the reference POM ( modified for some POM version into a directory retaining the clone directory structure )"
    echo "Example for running Ekstazi on Guava,"
    echo "POM needs to be changed only under guava-tests/pom.xml : so save it under a directory like"
    echo "			REFDIR/guava-tests/pom.xml and feed the REFDIR to the script when it is requested for during the execution"
    
    echo "**************************************************************************************************************"
    echo ###
    echo "Please input the script argurments "
    echo ###
    echo -e "CLONEURL : This is the path to git/svn repo [ currently supported for git ]         : \c"
    read CLONEURL
    echo -e "BASE COMMIT VERSION : This is the base commit revision number to start Ekstzi       : \c" 
    read BASEVERSION
    echo -e "ABSOLUTEPATH TO REFERNCE [ Default with modified pom files                          : \c" 
    read REFDIR
    echo -e "Number of commits to execute tests on                                               : \c"
    read REVCOUNT
    echo -e "Test command [ Default:mvn test] example 'cd guava-tests;mvn test'                  : \c"
    read TESTCMD
    echo -e "LOG SAVE DIRECTORY [ default:`pwd`/../logs/wEkstazi/                                :\c"
    read LOGDIR 
    
    echo "**************************************************************************************************************"
    echo #
    echo #
    echo "******"
    echo "INPUTS"
    echo "******"
    echo #
    echo "CLONEURL          : ${CLONEURL}"
    echo "BASEVERSION       : ${BASEVERSION}"
    echo "Number of Rev     : ${REVCOUNT}"
    echo "REF DIR 			: ${REFDIR}"
    echo "TEST COMMAND [ default mvn test ]       : ${TESTCMD}"
    echo "LOGDIR			: ${LOGDIR}"
    echo #
    echo "Press enter to continue after verification input" 
	if [ "${1}" == "demo" ] 
	then
    	read a
	fi
fi
}


installEKTAZI() {
		version=3.4.2
		url="mir.cs.illinois.edu/gliga/projects/ekstazi/release/"
		if [ ! -e org.ekstazi.core-${version}.jar ]; then wget "${url}"org.ekstazi.core-${version}.jar; fi
		if [ ! -e org.ekstazi.ant-${version}.jar ]; then wget "${url}"org.ekstazi.ant-${version}.jar; fi
		if [ ! -e ekstazi-maven-plugin-${version}.jar ]; then wget "${url}"ekstazi-maven-plugin-${version}.jar; fi


		mvn install:install-file -Dfile=org.ekstazi.core-${version}.jar -DgroupId=org.ekstazi -DartifactId=org.ekstazi.core -Dversion=${version} -Dpackaging=jar -DlocalRepositoryPath=$HOME/.m2/repository/
		mvn install:install-file -Dfile=ekstazi-maven-plugin-${version}.jar -DgroupId=org.ekstazi -DartifactId=ekstazi-maven-plugin -Dversion=${version} -Dpackaging=jar -DlocalRepositoryPath=$HOME/.m2/repository/
}

SCRIPTDIR=`pwd`
getInput "$@" 

>>>>>>> .r2465
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
<<<<<<< .mine
EKSTAZIBACKUPFOLDER="/tmp/${PROJECT}"
=======

PROJECT=`echo $CLONEURL | sed 's,/$,,g' | awk -F"/" '{print $NF}' | awk -F'.' '{print $1}'`
rm -rf /tmp/${PROJECT}
>>>>>>> .r2465
LOGNAME=$LOGDIR"/"${PROJECT}"_withEkstazi.log"
if [[ ${REFDIR} == "" ]] 
then
<<<<<<< .mine
    REFDIR=$SCRIPTDIR"/../logs/pomReferenceDir/"${PROJECT}"/"
    if [[ ! -d ${REFDIR} ]] 
    then
    coloredEcho "***** THIS PROGRAM REQUIRES USER TO HAVE REFERENCE POM SAVED IN THE PATH ${REFDIR} ******** "
    coloredEcho "QUITTING NOW!!!!"
    exit
    fi
=======
 	REFDIR=$SCRIPTDIR"/../logs/pomReferenceDir/"${PROJECT}"/"
	if [[ ! -d ${REFDIR} ]] 
	then
	echo "***** THIS PROGRAM REQUIRES USER TO HAVE REFERENCE POM SAVED IN THE PATH ${REFDIR} ******** "
	echo "QUITTING NOW!!!!"
	fi
>>>>>>> .r2465
fi


<<<<<<< .mine
#BACKUP EKSTAZI DIR
removeEkstaziDir ${EKSTAZIBACKUPFOLDER}
=======
if [ -d ${REPODIR}/${PROJECT} ] 
then
    echo "PROJECT PATH ${REPODIR}/${PROJECT} ALREADY EXISTS"
    cd ${REPODIR}/${PROJECT}
    ls
else
	# START CLONING THE PROJECT 
	cd ${REPODIR}
	echo "  ISSUING GIT CLONE COMMAND : git clone $CLONEURL" >> ${LOGNAME}
	git clone $CLONEURL
	cd ${REPODIR}/${PROJECT}
	ls
fi
>>>>>>> .r2465

<<<<<<< .mine
#CLONE REPO : IF NOT CREATED ALREADY
checkAndCloneRepo
=======
>>>>>>> .r2465

<<<<<<< .mine
#MOVE HEAD TO BASE VERSION
echo "ABOUT TO CHECKOUT"
#read a
cloneCheckout ${REPOFLAG} ${BASEVERSION}

echo "pwd : `pwd`"
#read a
#INSTALL SNAPSHOTS
#installSnapShots


#installing old
#installEKTAZI "3.4.2"
#installing new as well
#installEKTAZI "4.1.0"
coloredEcho "EKSTAZI INSTALLED"
#read a
#GET LAST N COMMITS TO GATHER DATA
getLastNCommits ${REPOFLAG}
#read a
echo $LASTNCOMMITS
=======
echo " MOVING HEAD TO BASE COMMIT"
git checkout $BASEVERSION
>>>>>>> .r2465

<<<<<<< .mine
=======
mvn install -DskipTests

echo ###
echo ###
echo ###
echo ###
echo ###
echo ###
echo "INSTALLING EKSTAZI"
#installEKTAZI
echo ###
echo ###
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> EKSTAZI INSTALLED"
echo ###
echo ###



# FETCH 20 MOST RECENT COMMIT INFORMATION
echo ">>>>>>>>>>>>>>>>>>>> FETCHING COMMIT INFORMATION FOR THE RECENT $REVCOUNT COMMITS"
#LASTNCOMMITS=`git log -n 100 --oneline | awk '{print $1}' | tail -2 |  tee /tmp/LASTNCOMMITS`
LASTNCOMMITS=`git log -n $REVCOUNT --oneline | awk '{print $1}' | tail -r`
echo $LASTNCOMMITS
diffpath=""
# RUN TARGET TEST FOR EACH COMMIT
>>>>>>> .r2465
IFS=$'\n'
<<<<<<< .mine
coloredEcho "#####"
coloredEcho "#####"
coloredEcho "You will be presented with ${REVCOUNT} files to modify"
coloredEcho "Please use \":wqa!\" to save the file and quit after modification or \":xa!\" to quit without saving. Press to continue"
coloredEcho "#####"
=======
echo "#####"
echo "#####"
echo "You will be presented with ${REVCOUNT} files to modify"
echo "Please use \":wqa!\" to save the file and quit after modification or \":xa!\" to quit without saving. Press to continue"
echo "#####"
echo "#####"
#read a
>>>>>>> .r2465

<<<<<<< .mine
=======
for i in ${LASTNCOMMITS}
do
	echo " >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> STARTING COMMIT FOR $i"
	git clean -fxd 
	#read a
	git checkout ${i}
	for file in `find ${REFDIR} -type f -name "*pom*" | grep -v "/SHA/"`
	do
		pomDel=`echo ${pomPath} | sed -E 's,^/+,,g'  | sed 's,^/,,g'`
		rm ${pomDel}
		git checkout ${pomDel}
	
	done
	#read a
	for file in `find ${REFDIR} -type f -name "*pom*" | grep -v "/SHA/"`
	do
	#read a
		echo "FILE IS " $file
		pomPath=`echo $file | sed "s,^.*${PROJECT},,g"`
		echo "POMPATH" ${pomPath}
		#copy the changed POM in BASEVERSION to ${i}
		mkdir -p ${REFDIR}"/SHA/"${i}"/"`dirname ${pomPath}`
		cp ${REFDIR}"/SHA/BASE_"${BASEVERSION}"/"${pomPath} ${REFDIR}"/SHA/"${i}"/"${pomPath}
		diffValue=`diff ${file} ${REPODIR}/${PROJECT}/${pomPath} | grep ^[\>\<] | wc -l | awk '{print $1}'`
		echo ${diffValue}
		# if the new version pom is different from baseversions original pom ( without modification ) 
		# show vimdiff and save the changes under ${i} pom dif
		if [[ ${diffValue} -ne 0 ]] 
		then
			diffValue2=`diff ${REFDIR}"/SHA/BASE_"${BASEVERSION}"/"${pomPath} ${REPODIR}"/"${PROJECT}"/"${pomPath}`
			echo ${diffValue2}
	#read a
			if [[ ${diffValue2} -ne 0 ]] 
			then
			#cp ${REPODIR}"/"${PROJECT}"/"${pomPath} ${REFDIR}"/SHA/"${i}"/"`dirname ${pomPath}`
			#vimdiff ${REFDIR}"/SHA/"$BASEVERSION"/"$pomPath ${REPODIR}/${PROJECT}/${pomPath}
				vimdiff ${REFDIR}"/SHA/BASE_"${BASEVERSION}"/"${pomPath} ${REPODIR}"/"${PROJECT}"/"${pomPath} 
		    #$${REFDIR}"/SHA/"${i}"/"${pomPath}
				cp ${REPODIR}"/"${PROJECT}"/"${pomPath} ${REFDIR}"/SHA/"${i}"/"`dirname ${pomPath}`
			fi
		fi
	#read a
	done
done
>>>>>>> .r2465
#clear
<<<<<<< .mine
saveReferencePOMS
#read a

=======
echo ###
>>>>>>> .r2465
echo "DONE WITH POM CHANGES FOR ALL THE ${REVCOUNT} VERSIONS"
<<<<<<< .mine
coloredEcho "STARTING TO EXECUTE WITH POM CHANGES FOR EKSTAZI. Press enter to continue"
=======
echo ###
echo ###

echo "PWD :  `pwd`"
echo "STARTING TO EXECUTE WITH POM CHANGES FOR EKSTAZI. Press enter to continue"
>>>>>>> .r2465
> ${LOGNAME}
<<<<<<< .mine
#read a
#START EXECUTION 
runWithEkstazi
exit


cd $SCRIPTDIR
=======
for i in ${LASTNCOMMITS}
do
# RUN TEST FOR EACH COMMIT
	echo ">>>>>>>>>>>>>>>>>>>> BEGIN COMMIT : $i : ">> ${LOGNAME}
	echo `date` >> ${LOGNAME}
	backupEkstazi
	git clean -fxd 
	git checkout ${i}
	restoreEkstazi
	for file in `find ${REFDIR} -type f -name "*pom*" | grep "/SHA/BASE_${BASEVERSION}/"`
	do
		pomPath=`echo $file | sed "s,^.*${PROJECT}//SHA/BASE_${BASEVERSION}/,,g" | sed 's,^/,,g'`
		pomDel=`echo ${pomPath} | sed -E 's,^/+,,g'  | sed 's,^/,,g'`
		rm ${pomDel}
		git checkout ${pomDel}
		echo "CHECKING OUT POM >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
		cp ${REFDIR}"/SHA/"${i}"/"${pomPath} ${REPODIR}"/"${PROJECT}"/"$pomPath
	done
	echo "RUNNING $TESTCMD "
	#eval $TESTCMD 
	mvn test | tee -a ${LOGNAME}
	echo ">>>>>>>>>>>>>>>>>>>> END OF EXECUTION FOR $i " >> ${LOGNAME}
done
#clear
cd $PPWD
>>>>>>> .r2465
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
