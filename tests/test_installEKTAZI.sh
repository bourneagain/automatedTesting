source ../includeFunctions.sh
LOGFILE="logs/test_installEKTAZI.log"
> ${LOGFILE}
testLogger INFO "EKSTAZI INSTALLATION BEGINS" ${LOGFILE} 
#EXECUTING FUNCTION CALL
installEKTAZI 4.2.0 

ls -1 ${HOME}/.m2/repository/org/ekstazi > /tmp/installEkstaziTest.log
ekstazi_maven_plugin_count=`grep -c ekstazi-maven-plugin /tmp/installEkstaziTest.log`
org_ekstazi_core_count=`grep -c org.ekstazi.core /tmp/installEkstaziTest.log`
if [[ ${ekstazi_maven_plugin_count} -eq 1 ]] 
then
	if [[ ${org_ekstazi_core_count} -eq 1 ]]
	then
		testLogger SUCCESS "INSTALLED EKSTAZI PLUGINS" ${LOGFILE} 
	else
		testLogger FAIL "CHECK |org_ekstazi_core| INSTALLATION FAILED" ${LOGFILE} 
	fi
else
	testLogger FAIL "CHECK |ekstazi_maven_plugin| INSTALLATION FAILED" ${LOGFILE} 
fi	

testLogger INFO "EKSTAZI INSTALLATION ENDS" ${LOGFILE} 
