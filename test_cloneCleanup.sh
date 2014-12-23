source ../includeFunctions.sh
LOGFILE="logs/test_cloneCleanup.log"
touch ${LOGFILE}
> ${LOGFILE}
testLogger INFO "BEGIN CLONE CLEANUP TEST" ${LOGFILE} 
bash -ux ./test_pullClone.sh "https://github.com/JodaOrg/joda-time.git" "http://svn.apache.org/repos/asf/logging/log4j/trunk/" "CLEAN" ${LOGFILE}

testLogger INFO "CLONE CLEANUP TEST ENDS" ${LOGFILE} 

# dependant tests invoked
