source ../includeFunctions.sh
pwd=`pwd`
LOGFILE=${pwd}/"logs/test_ekstaziReductionCheck.log"
touch ${LOGFILE}
> ${LOGFILE}
testLogger INFO "BEGIN TEST" ${LOGFILE} 
cd ..
rm -rf ../logs/repoDir/joda-time
./executeTestWithEkstazi.sh auto https://github.com/JodaOrg/joda-time.git f36072e1 1 '' '' git joda-time 2.13 . 4.2.0 '' test

testLogger INFO "TESTING COMPLETE; VERIFICATION BEGINS" ${LOGFILE} 
 
python collateTime.py ../logs/wEkstazi/joda-time_withEkstazi.log >  /tmp/joda_test.log
start=`grep -v commit /tmp/joda_test.log | head -1 | awk -F, '{print $3}'`
end=`grep -v commit  /tmp/joda_test.log| tail -1 | awk -F, '{print $3}'`
percent=`bc <<< ${start}-${end}`
percent=`bc <<< "scale=2;${percent}/${start}*100"`
if [[ ${percent} -eq 0 ]] 
then
   testLogger FAIL "TEST FAILURE: REDUCTION % ${percent}" ${LOGFILE} 
else
   testLogger SUCCESS "TEST SUCCESS : REDUCTION % ${percent}" ${LOGFILE} 
fi
testLogger INFO "EKSTAZI TEST ENDS" ${LOGFILE} 
rm /tmp/joda_test.log
