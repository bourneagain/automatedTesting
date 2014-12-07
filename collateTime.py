################################
# Author : Shyam Rajendran     #
# Version : 1.2                #
# About : Script to collate execution details when a revision results in multiple execution stats         
################################
import sys
import re
from os import system
if len(sys.argv) == 2:
	script,filepath=sys.argv



vCount=0;
regexMatchVersionStart=re.compile(">>>>>>>>>>>>>>>>>>>> BEGIN COMMIT : (.+) :")
regexMatchEnd=re.compile(">>>>>>>>>>>>>>>>>>>> END OF EXECUTION FOR")
regexMatchTestLine=re.compile("Tests run:") 
regexMatchEmptyLine=re.compile("^$") 

def splitVersions(path):
	global regexMatchVersionStart
	global regexMatchEnd 
	global vCount
	version=""
	data=[]
	begin=0
	with open(path) as f:
    		for line in f:
			if regexMatchVersionStart.match(line):
				data.append(line)
				begin=1	
				version=regexMatchVersionStart.match(line).group(1)
			if regexMatchEnd.match(line):
				data.append(line)
				summary(version,data)
				data=[]
				begin=0	
				vCount=vCount+1
				#print "SETTING BEGIN 0 "
			if begin:
				data.append(line)

def parseTime(timeElapsed):
	if timeElapsed == "NA":
		return "NA"
	#print timeElapsed
	#01:05 min
	#1:56.074s
	min=timeElapsed.split(':')[0]
	try:
		sec=timeElapsed.split(':')[1]
	except IndexError:
		sec=min
		sec=re.sub('\s+s', '', sec).split('.')[0]
		return int(sec)
		
	sec=re.sub('s', '', sec).split('.')[0]
	sec=re.sub('min', '', sec).split('.')[0]
	#print min
	#print sec
	# parseTime.sec+=int(sec)
	# parseTime.min+=int(min)
	return int(min)*60+int(sec)
		
def findMatch(Array,checkString):
	#print "SEARHING for " + checkString ,
	#print Array
	for i, ele in enumerate(Array):
		if re.search(checkString, ele):
	#		print "found " + str(i)
			return i
	return -1

def summary(version,data):
	#system('clear')
	#print "SUMMARY <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> " + str(len(data))
	global regexMatchEnd
	global regexMatchTestLine 
	global regexMatchEmptyLine 
	global regexMatchVersionStart
	global vCount
	regexMatchTimeLine=re.compile("Total time: (.*)") 
	timeElapsed="NA"
	
	tcSum=etSum=failSum=lineSum=linec=errorSum=skipSum=entered=0
	for line in data:
		linec+=1
		if regexMatchEmptyLine.match(line):
			continue	
		if regexMatchTimeLine.search(line):
			timeElapsed=regexMatchTimeLine.search(line).group(1)
		if regexMatchTestLine.match(line):
			linearray=line.split(',')
			#print linearray
			testIndex=findMatch(linearray,'Tests run');
			timeIndex=findMatch(linearray,'Time elapsed');
			failIndex=findMatch(linearray,'Failures');
			skipIndex=findMatch(linearray,'Skipped');
			errorIndex=findMatch(linearray,'Errors');
			if skipIndex == -1 or errorIndex == -1 or testIndex == -1 or failIndex == -1 or timeIndex == -1:
				continue
				pass

			try:
					#print linearray[skipIndex].split(':')[1] 
					if skipIndex != -1 :
						skipSum+=int(linearray[skipIndex].split(':')[1])
					if errorIndex != -1 :
						errorSum+=int(linearray[errorIndex].split(':')[1])
					if testIndex != -1 :
						tcSum+=int(linearray[testIndex].split(':')[1])
					if timeIndex != -1 :
						etSum+=float(linearray[timeIndex].split(':')[1].split()[0])
					if failIndex != -1 :
						failSum+=int(linearray[failIndex].split(':')[1])  
			except IndexError:
					print "INDEX ERROR " ,
					print linearray
					print "----"
	print str(vCount)+','+version+","+str(tcSum)+","+str(failSum) + "," + str(errorSum) +  "," +  str(skipSum)+ ","+str(parseTime(timeElapsed))

#total(filepath)
print "commit-n,version,Tests run,Failures,Errors,Skipped,Time elapsed"
splitVersions(filepath)
