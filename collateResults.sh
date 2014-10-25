#!/bin/bash
################################################################################################
# About : Script to collect execution logs of various projects and output a CSV for charting
# Author : Shyam Rajendran
################################################################################################
LOGDIR=$1
PWD=`pwd`

COLLATESCRIPTPATH=`find . -type f -name "collateTime.py" | tail -1`
GENERATETABLESCRIPTPATH=`find . -type f -name "generateChart.sh"| tail -1`

echo ###
echo ###
echo "STARTING TO COLLECT RUN DETAILS....."
echo ###
echo ###
for j in `find $LOGDIR -type f -name "*.log"`
do
	echo -ne "COLLETING RUN DETAILS FOR $j"
	python $COLLATESCRIPTPATH $j > ${j}.TABLE
	echo ": DONE"
done
echo ###
echo ###
echo ###
echo "CREATING FINAL SUMMARY TABLE"
echo ###
echo ###
bash $GENERATETABLESCRIPTPATH $LOGDIR | tee  $LOGDIR"/"import.csv

echo ###
echo ###
echo ###
echo "IMPORT $LOGDIR"/"import.csv to CHART"
echo ###
echo ###
echo ###
echo ###
