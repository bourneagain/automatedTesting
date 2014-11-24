#!/bin/bash 
coloredEcho(){
    local exp=$1;
    tput setaf 2;
    echo $exp;
    tput sgr0;
}

clear
SCRIPTPATH=`pwd`
mkdir -p ../logs/repoDir 
cd ../logs/repoDir/
#clone JODA-TIME
coloredEcho ">>>>>>>>>>>>>>>>>>>>> CLONING JODA_TIME"
git clone https://github.com/JodaOrg/joda-time.git
#checkout specific SHA [ for testing ] 
cd joda-time
coloredEcho ">>>>>>>>>>>>>>>>>>>>> CHECKINGOUT BASE SHA f36072e1"
BASE=f36072e1
git checkout ${BASE} 

coloredEcho ">>>>>>>>>>>>>>>>>>>>> INSTALLING EKSTAZI"
#install ekstazi
${SCRIPTPATH}/installEkstazi.sh

coloredEcho ">>>>>>>>>>>>>>>>>>>>> MODIFY POM FOR THIS SHA [ from reference POM already saved ] "
# change POM for ekstazi
cp -f ${SCRIPTPATH}/../logs/pomReferenceDir/joda-time/SHA/BASE_f36072e/pom.xml .

coloredEcho ">>>>>>>>>>>>>>>>>>>>> CREATE .ekstazirc file with text \"dependencies.format=txt\""
# create file .ekstazirc
coloredEcho ">>>>>>>>>>>>>>>>>>>>> dependencies.format=txt" > .ekstazirc

coloredEcho ">>>>>>>>>>>>>>>>>>>>> RUNNING MVN TEST : Logs saved under /tmp/joda-time_${BASE}.log"
sleep 2
mvn test | tee  /tmp/joda-joda_${BASE}.log

