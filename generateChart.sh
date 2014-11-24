
#./wEkstazi/Netty_wEkstazi.log.TABLE
#./woEkstazi/guava_woEkstazi.log.TABLE
#./woEkstazi/netty_woEkstazi.log.TABLE
if [[ $# -lt 1 ]] 
then
	echo "USAGE: generateChart.sh <LOGDIR>"
	exit
fi

LOGDIR=$1
cd $LOGDIR

echo "project,commit-n,version,Tests run,Failures,Errors,Skipped,Time elapsed,W/O Ekstazi"
for i in  `find . -name "*.TABLE"`
	do
		project=`echo $i | awk -F"/" '{print $NF}' | awk -F'_' '{print $1}' | tr '[:upper:]' '[:lower:]'`
		flag=`echo $i | awk -F'/' '{print $2}'` 
		sed -e "s/^/$project,/g" -e "s/$/,$flag/g" $i  
	done | grep -v "Tests"  
