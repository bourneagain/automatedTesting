#!/bin/bash
# Before running this script the following was done:

# 2 did the necessary changes in build.xml to integrate with ekstazi (following ant specific instructions)
# (the build.xml used is also submitter)
# 

project=nutch
cwd=`pwd`
if [ ! -d nutch ]; then
svn checkout https://svn.apache.org/repos/asf/nutch/trunk/
fi

# Print info about the machine.
cat /proc/cpuinfo > cpu.info
cat /proc/meminfo > mem.info

function hw() {
    revision="${1}"
	cd trunk
	svn up -r ${revision}

     # Run the tests.
     
     ant test 
     cd ..
}

function run()
{
	hw 1610628 
	hw 1610635 
	hw 1610956
	hw 1614375
	hw 1618725
	hw 1619934
	hw 1622354 
	hw 1622377 
	hw 1622510
	hw 1622621	
	hw 1622623
	hw 1622946
	hw 1623562
	hw 1626517
	hw 1626581
	hw 1627028 
	hw 1627455
	hw 1627456
	hw 1628329
	hw 1630565 

	

}
run | tee -a nutchlog2.txt
sed -i 's/.*'"${cwd//\//\\/}"'/USER/g' nutchlog2.txt
