#!/bin/bash

# Ekstazi version
name="nutch"
version="3.5.0"
project="<project name="${name}" default="runtime" xmlns:ivy="antlib:org.apache.ivy.ant" xmlns:artifact="antlib:org.apache.maven.artifact.ant" 	 xmlns:ekstazi="antlib:org.ekstazi.ant">"
taskdef="<taskdef uri="antlib:org.ekstazi.ant" resource="org/ekstazi/ant/antlib.xml"><classpath path="org.ekstazi.core-3.4.2.jar"/>
<classpath path="org.ekstazi.ant-3.4.2.jar"/></taskdef>"
ekstaziselection="<ekstazi:selection>"
jvmarg="<jvmarg value="-javaagent:org.ekstazi.core-3.4.2.jar=junitMode" />"
sekstaziselection=" </ekstazi:selection>"



function run() {
        rev="$1"
	project_line="$2"
       	taskdef_line="$3"
	ekstaziselection_line="$4"
	jvmarg_line="$5"
	sekstaziselection_line="$5"
      

        svn revert build.xml
        svn up -r${rev}
        sed -i "${project_line}i\\${project}" build.xml
        sed -i "${taskdef_line}i\\${taskdef}" build.xml
        sed -i "${ekstaziselection_line}i\\${ekstaziselection}" build.xml
	sed -i "${jvmarg_line}i\\${jvmarg}" build.xml
        sed -i "${sekstaziselection_line}i\\${sekstaziselection}" build.xml 
        # Compile separate not to measure time
        #mvn test-compile
        # Run tests
        ant test
}

function exec() {
        ( cd trunk;
		
                 run "1610635 " "18" "19" "438" "441" "453"
                #run "1588037" "536" "540" "471"
               #run "1622800" "536" "540" "471"
           
        )
}

# Clone repository
if [ ! -d nutch ]; then
svn checkout https://svn.apache.org/repos/asf/nutch/trunk/
else
        rm -rf trunk/.ekstazi
fi


# Check if clone was good
if [ ! -d trunk ]; then
        echo "Nothing was cloned"
        exit 1
fi

# Download Ekstazi
url="mir.cs.illinois.edu/gliga/projects/ekstazi/release/"
if [ ! -e org.ekstazi.core-${version}.jar ]; then wget "${url}"org.ekstazi.core-${version}.jar; fi
if [ ! -e org.ekstazi.ant-${version}.jar ]; then wget "${url}"org.ekstazi.ant-${version}.jar; fi
if [ ! -e ekstazi-maven-plugin-${version}.jar ]; then wget "${url}"ekstazi-maven-plugin-${version}.jar; fi

# Install Ekstazi
mvn install:install-file -Dfile=org.ekstazi.core-${version}.jar -DgroupId=org.ekstazi -DartifactId=org.ekstazi.core -Dversion=${version} -Dpackaging=jar -DlocalRepositoryPath=$HOME/.m2/repository/
mvn install:install-file -Dfile=ekstazi-maven-plugin-${version}.jar -DgroupId=org.ekstazi -DartifactId=ekstazi-maven-plugin -Dversion=${version} -Dpackaging=jar -DlocalRepositoryPath=$HOME/.m2/repository/

# Run tests with Ekstazi over five revisions
cwd=`pwd`
exec | tee nutchlogwithekstazi.txt
sed -i 's/.*'"${cwd//\//\\/}"'/USER/g' nutchlogwithekstazi.txt
#grep -A 5 "Results :" step3.txt | grep Tests > table3.txt
