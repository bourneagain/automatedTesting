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
	
def summary(version,data):
	#system('clear')
	#print "SUMMARY <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> " + str(len(data))
	global regexMatchEnd
	global regexMatchTestLine 
	global regexMatchEmptyLine 
	global regexMatchVersionStart
	global vCount
	tcSum=etSum=failSum=lineSum=linec=errorSum=skipSum=entered=0
	for line in data:
		#print "VERSION IS " + version+":"+line
		linec+=1
		if regexMatchEmptyLine.match(line):
			continue	
		if regexMatchTestLine.match(line):
			#print "MATCH LINE " + line
			linearray=line.split()
			if len(linearray) == 9:
				continue

			#Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.01 sec
			tcSum+=int(linearray[2].replace(",", ""))
			etSum+=float(linearray[11].replace(",", ""))
			failSum+=int(linearray[4].replace(",", ""))
			skipSum+=int(linearray[8].replace(",", ""))
			errorSum+=int(linearray[6].replace(",", ""))
	print str(vCount)+','+version+","+str(tcSum)+","+str(failSum) + "," + str(errorSum) +  "," +  str(skipSum)+ ","+str(etSum)

#total(filepath)
print "commit-n,version,Tests run,Failures,Errors,Skipped,Time elapsed"
splitVersions(filepath)
