#!/bin/bash

cwd=`pwd`

if [ -z "$1" ]; then
	echo "No argument supplied. Please run the program as ./run_ekstazi.sh {git|svn}_project_url [local_folder_name] [ekstazi_version]"
	echo "Arguments in [] are optional."
	exit 0
fi

default_location="mvn_test_project"
project_url=""
project=${default_location}
version="4.2.0"
git_project="0"
surefire_version="0.0"
modules="."
clean_all="false"
project_revision="0"

while getopts ":u:p:v:s:m:r:c:h" opt; do
  case $opt in
  	u)
      #echo "-url was triggered! Parameter: ${OPTARG}" >&2
      project_url=${OPTARG};
      ;;
    p)
      #echo "-pname was triggered! Parameter: ${OPTARG}" >&2
      project=${OPTARG}
      ;;
    v)
      #echo "-ek_version was triggered! Parameter: ${OPTARG}" >&2
      version=${OPTARG}
      ;;
    s)
      #echo "-surefire_version was triggered! Parameter: ${OPTARG}" >&2
      surefire_version=${OPTARG}
      ;;
   	m)
   	  #echo "-modules was triggered! Parameter: ${OPTARG}" >&2
   	  modules=(${OPTARG//,/ })
      ;; 
	r)
	  project_revision="${OPTARG}"
	  ;;
	c)
	  clean_all=${OPTARG}
	  ;;
    h)
	  echo "help-> ./run_ekstazi.sh -u [svn/git project url] -p [local_project_folder_name] -v [ekstazi_version] -s [forced_surefire_version] -m [modules separated by ,] -r [revision/otherwise latest] -c [true/false to clean local cloned projects]" >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ "$clean_all" == "true" ]; then
	pclones=`ls -la ${cwd} | grep ".*_clone" | awk '{print $9}'`
	echo $pclones
	for fclone in ${pclone}; do
		pfolder=`echo "${fclone}" | sed -e 's/^\.//g' | sed -e 's/_clone//g'`
		echo $fclone
		echo $pfolder
	done
	exit 1;
fi

surefire_check=$(awk 'BEGIN{ print "'${surefire_version}'"=="0.0" }')
#echo "Surefire Version"
#echo $surefire_check

clone_project_dir=".${project}_clone"
echo $clone_project_dir
echo $project_url
echo $project
echo $version
echo $surefire_version

for index in "${!modules[@]}"
do
    echo -n "${modules[index]},"
done
echo ''

rm -rf ${default_location}


protocol=`echo $project_url | cut -d':' -f 2`
git_project_url="git:${protocol}"
#echo $protocol
#echo $git_project_url
git_project=`timeout 5 git ls-remote $project_url 2> /dev/null | wc -l | tail -1 | awk '{if ($1 > 0) {print "0"} else {print "1"}}'`

if [ $git_project -ne "0" ]; then 
	git_project=`timeout 5 git ls-remote $git_project_url 2> /dev/null | wc -l | tail -1 | awk '{if ($1 > 0) {print "0"} else {print "1"}}'`
fi

if [ ! -d "${clone_project_dir}" ]; then

	rm -rf ${project}

	if [ $git_project -eq "0" ]; then
		echo "A Git project"
		git clone ${project_url} ${project}
	else
		echo "Not a git project"
		echo "Try if it's an svn project"
		svn co ${project_url} ${project}
	fi
	cp -r ${project} ${clone_project_dir}
else
	rm -rf ${project}
	cp -r ${clone_project_dir} ${project}
	#	rm -rf ${project}/.ekstazi
fi

## Check if clone was good
if [ ! -d "${project}" ]; then
       echo "Nothing was cloned. Check if the url is valid git or svn url."
       exit 1
fi

cd ${project}

if [ "$project_revision" != "0" ]; then
	echo "Changing revision to $project_revision"
	if [ $git_project -eq "0" ]; then
		git checkout $project_revision
	else
		svn up -r"${project_revision}"
	fi
else
	echo "Using latest revision"
	if [ $git_project -eq "0" ]; then
		git checkout
	else
		svn up
	fi
fi

#rm -rf pom.xml
#
#if [ $git_project -eq "0" ]; then
#	git checkout pom.xml
#	git checkout
#else	
#	svn up
#fi

# Download Ekstazi
# url="mir.cs.illinois.edu/gliga/projects/ekstazi/release/"
# if [ ! -e org.ekstazi.core-${version}.jar ]; then wget "${url}"org.ekstazi.core-${version}.jar; fi
# if [ ! -e org.ekstazi.ant-${version}.jar ]; then wget "${url}"org.ekstazi.ant-${version}.jar; fi
# if [ ! -e ekstazi-maven-plugin-${version}.jar ]; then wget "${url}"ekstazi-maven-plugin-${version}.jar; fi

# Install Ekstazi
#mvn install:install-file -Dfile=org.ekstazi.core-${version}.jar -DgroupId=org.ekstazi -DartifactId=org.ekstazi.core -Dversion=${version} -Dpackaging=jar -DlocalRepositoryPath=$HOME/.m2/repository/
#mvn install:install-file -Dfile=ekstazi-maven-plugin-${version}.jar -DgroupId=org.ekstazi -DartifactId=ekstazi-maven-plugin -Dversion=${version} -Dpackaging=jar -DlocalRepositoryPath=$HOME/.m2/repository/

mvn install -DskipTests

for index in "${!modules[@]}"

do
	echo "In project ${modules[index]},"
	
	cd ${modules[index]}
	
	if [ $surefire_check -eq "1" ]; then
		java -jar ${cwd}/pom_parser.jar "${cwd}/${project}" "${version}" 	
	else
		java -jar ${cwd}/pom_parser.jar "${cwd}/${project}" "${version}" "${surefire_version}" 	
	fi
    
	${cwd}/test_ekstazi.sh .

done

cd ${cwd}
