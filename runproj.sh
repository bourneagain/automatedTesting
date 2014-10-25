#!/bin/bash
export project=Hama
export cwd=`pwd`

# Clone repository
if [ ! -d Hama ]; then
    svn checkout http://svn.apache.org/repos/asf/hama/trunk/ ${project}
fi
#LOGFILE=/project/Hamatemp.txt
function runHama() {
	echo ">>>>>>>>>>>>>>>>>>>> BEGIN COMMIT :" >> Hamalog1.txt
    revision="${1}"
    # Go to a specific revision.
    ( cd ${project}; svn up -r"${revision}" )
     # Run the tests.
    ( cd ${project}; mvn test )
	echo ">>>>>>>>>>>>>>>>>>>> END COMMIT :" >> Hamalog1.txt
}

function runTests() {
    ( cd Hama;
	
 	#runHama "1598471"
	#runHama "1599853"
	#runHama "1604335"
	#runHama "1607015"
	#runHama "1607244"
	#runHama "1608994"
	#runHama "1610643"
	#runHama "1611601"
	#runHama "1615467"
	#runHama "1617395"
	#runHama "1619962"
	#runHama "1620825"
	#runHama "1620830"
	#runHama "1621000"
	#runHama "1621061"
	runHama "1621219"
	runHama "1628353"
	runHama "1628356"
	runHama "1630222"
	runHama "1630227"

    )
}

# Running tests without Ekstazi.
runTests | tee -a Hamalog1.txt
sed -i 's/.*'"${cwd//\//\\/}"'/USER/g' Hamalog1.txt
#grep 'sec -' step1.txt | cut -f1,5 -d',' | cut -f1 -d'-' > table2.txt
#grep -A 5 "Results :" step2.txt | grep Tests > table2.txt

