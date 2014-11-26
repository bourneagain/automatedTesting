#!/bin/bash

cd $1

find ./ -iname ".ekstazi" -exec rm -rf {} \;


t1=$(date +"%s")

trun1=`mvn test -fae | tee /dev/tty | awk '/Results :/{y=1;next}y'| grep -i "Tests run: " | awk '{print $3}' | cut -d',' -f 1`

t2=$(date +"%s")

trun2=`mvn test -fae | tee /dev/tty | awk '/Results :/{y=1;next}y'| grep -i "Tests run: " | awk '{print $3}' | cut -d',' -f 1`

t3=$(date +"%s")

if [ -z "$trun1" ]
then
	trun1=0
	echo "Some problem in running tests"
	exit 0
fi

if [ -z "$trun2" ]
then
	trun2=0
fi


ek_folders=`find ./ -iname ".ekstazi" -print`

for ekFolder in ${ek_folders}; do
	if [ -d ${ekFolder} ]; then
		ekstazi_gen=`ls -ltr ${ekFolder} | wc -l | awk '{if ($1 > 1) print "1"; else print "0";}'`
		#echo -n $ekFolder
		#echo -n $ekstazi_gen
		module_name=`echo $ekFolder  | sed -e 's/\/\.ekstazi//g' | sed -e 's/^\.\///g'`
		echo -n "Module -> ${module_name} -> "
		if [ $ekstazi_gen -eq "1" ]; then
			echo "Passed"
		else
			echo "Failed"
		fi
	fi
done


IFS=', ' read -a tests_array <<< "$trun1"
trun1=0
for element in "${tests_array[@]}"
do
	trun1=$(( $trun1 + $element ))
done

IFS=', ' read -a ek_tests_array <<< "$trun2"
trun2=0
for element in "${ek_tests_array[@]}"
do
	trun2=$(( $trun2 + $element ))
done

time_diff=$(($t2-$t1))
time_diff2=$(($t3-$t2))

echo ""
echo "Time taken for first run = $(($time_diff / 60)) minutes and $(($time_diff % 60)) seconds."
echo "Time taken for first run = $(($time_diff2 / 60)) minutes and $(($time_diff2 % 60)) seconds."


echo ""
echo "Number of tests that ran first time = " $trun1
echo "Number of tests that ran second time = " $trun2
echo ""

tdiff=`expr ${trun1} - ${trun2}`

echo "Difference of testcases that ran = " $tdiff

if [ $tdiff -eq $trun1 ]
then
	echo "Tests reduced 100% successfully"
elif [ $tdiff -gt 0 ]
then
	echo "Some of the tests were reduced by ekstazi."
elif [ $tdiff -eq 0 ]
then	
	echo "Ekstazi didn't ran successfully. Check pom configuration again."
else
	echo "Something wrong here. Check pom configuration again."
fi

