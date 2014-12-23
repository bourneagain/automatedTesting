source ../includeFunctions.sh
LOGFILE="logs/test_pullClone.log"
> ${LOGFILE}
pwd=`pwd`
testLogger INFO "BEGIN CLONNING TEST" ${LOGFILE} 

PROJECT="/tmp/dummy_test_pullClone"
rm -rf ${PROJECT}
mkdir ${PROJECT}
testLogger INFO "GIT CLONE TEST" ${LOGFILE} 
pullClone git $1 ${PROJECT}
cloneCount=`ls -l ${PROJECT} | wc -l`
successCount=0
if [[ ${cloneCount} -gt 1 ]] 
then
   testLogger SUCCESS "GIT CLONE PASSED " ${LOGFILE} 
   successCount=1
else
   testLogger FAIL "GIT CLONE FAILED" ${LOGFILE} 
fi

if [[ $3 == "CLEAN" ]] 
then
   testLogger INFO "CLONE CLEANUP CODE CHECK BEINGS" ${4} 
   cd ${PROJECT}
   touch _junkFile1
   touch _junkFile2
   BEFORE=`ls _junkFile* | wc -l`
   cloneCleanup git
   AFTER=`ls _junkFile* | wc -l` 
   if [[ ${AFTER} -eq 0 ]] 
   then
       testLogger PASS "GIT CLONE CLEANUP PASSED " ${pwd}/${4}
   else
       testLogger FAIL "GIT CLONE CLEANUP FAILED" ${pwd}/${4}
   fi
   cd ..
fi


rm -rf ${PROJECT}
mkdir ${PROJECT}

testLogger INFO "SVN CLONE TEST" ${LOGFILE} 


pullClone svn $2 ${PROJECT}
if [[ ${cloneCount} -gt 1 ]] 
then
   testLogger PASS "SVN CLONE PASSED " ${LOGFILE} 
   successCount=2
else
   testLogger FAIL "GIT CLONE FAILED" ${LOGFILE} 
fi
if [[ ${successCount} -eq 2 ]] 
then
   testLogger SUCCESS "CLONE TEST PASSED" ${LOGFILE} 
fi

if [[ $3 == "CLEAN" ]] 
then
   testLogger INFO "CLONE CLEANUP CODE CHECK BEINGS" ${4} 
   cd ${PROJECT}
   touch _junkFile1
   touch _junkFile2
   BEFORE=`ls _junkFile* | wc -l`
   cloneCleanup svn 
   AFTER=`ls _junkFile* | wc -l` 
   if [[ ${AFTER} -eq 0  ]] 
   then
       testLogger PASS "SVN CLONE CLEANUP PASSED " ${pwd}/${4}
   else
       testLogger FAIL "SVN CLONE CLEANUP FAILED" ${pwd}/${4}
   fi
   cd ..
fi
rm -rf ${PROJECT}
mkdir ${PROJECT}

testLogger INFO "CLONNING TEST END" ${LOGFILE} 
