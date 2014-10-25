LOGFILE=$1
for i in `find . -name *.log`
do
commit=`echo $i| awk -F'/' '{print $NF}'`
echo ">>>>>>>>>>>>>>>>>>>> BEGIN COMMIT : $commit : ">> $LOGFILE
cat $i >> $LOGFILE
echo ">>>>>>>>>>>>>>>>>>>> END OF EXECUTION FOR $commit ">> $LOGFILE
done

