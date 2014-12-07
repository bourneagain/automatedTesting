about(){
    echo "**********"
    echo "About"
    echo "**********"
    echo "This script is used for empirical evaluation of Ekstazi across multiple projects and revision. It partially automates the effort of changing pom files per revision"
    echo "" 
    echo "**********"
    echo "Usage"
    echo "**********"
    echo "./executeTestWithEkstazi.sh <args>"
    echo "ARGS"
}


installEKTAZI() {
    version=$1
    url="mir.cs.illinois.edu/gliga/projects/ekstazi/release/"
    if [ ! -e org.ekstazi.core-${version}.jar ]; then wget "${url}"org.ekstazi.core-${version}.jar; fi
    if [ ! -e org.ekstazi.ant-${version}.jar ]; then wget "${url}"org.ekstazi.ant-${version}.jar; fi
    if [ ! -e ekstazi-maven-plugin-${version}.jar ]; then wget "${url}"ekstazi-maven-plugin-${version}.jar; fi


    mvn install:install-file -Dfile=org.ekstazi.core-${version}.jar -DgroupId=org.ekstazi -DartifactId=org.ekstazi.core -Dversion=${version} -Dpackaging=jar -DlocalRepositoryPath=$HOME/.m2/repository/
    mvn install:install-file -Dfile=ekstazi-maven-plugin-${version}.jar -DgroupId=org.ekstazi -DartifactId=ekstazi-maven-plugin -Dversion=${version} -Dpackaging=jar -DlocalRepositoryPath=$HOME/.m2/repository/
}

backupEkstazi() {
    for ekstaziFolder in `find ${REPODIR}/${PROJECT} -type d -name ".ekstazi"`
    do
        #rm -rf /tmp/{PROJECT}/ 2>&1 > /dev/null 
        #copy part
        savePath=`echo ${ekstaziFolder} | sed "s,^.*${PROJECT}/,,g" | sed 's,^/,,g'`
        mkdir -p /tmp/${PROJECT}/${savePath}
        coloredEcho "BACKING UP EKSTAZI >>>>>>>>>>>>>>>>>>>>>>>>  mv ${ekstaziFolder} /tmp/${PROJECT}/${savePath}"
        mv ${ekstaziFolder}/* /tmp/${PROJECT}/${savePath}
    done
}

restoreEkstazi() {
    PN=${PROJECT}
    if [ -d /tmp/${PROJECT} ] 
    then
      for backUpFolder in `find /tmp/${PN}/ -type d -name ".ekstazi"`
      do
        savePath=`echo ${backUpFolder}| sed "s,^.*${PROJECT}/,,g" | sed 's,^/,,g'`
        echo ${savePath}
        mkdir -p ${REPODIR}"/"${PROJECT}/${savePath}
        coloredEcho "mv ${backUpFolder}/* ${PROJECT}/${savePath}"
        mv ${backUpFolder}/* ${REPODIR}/${PROJECT}/${savePath}
      done
    fi
}

coloredEcho(){
    local exp=$1;
    tput setaf 2;
    echo #
    echo `date`
    echo $exp;
    echo `date`
    echo #
    tput sgr0;
}

getOptions(){
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
          esac
    done
}

getInput() {
    clear
    if [[ "$1" == "demo" || "$1" == "auto" ]] ;then
        # 1 "demo"
        # 2 $CLONEURL
        # 3 $BASEVERSION
        # 4 $REVCOUNT
        # 5 "$LOGDIR"
        # 6 "${TESTCMD}"
        # 7 "${REPOFLAG}"
        # 8 "${PROJECT}"
        # 9 "${surefire_version}"
        # 10 ("${modules}")
        # 11 "${version}"
        # 12 "{patch}"
        version="4.2.0"
        git_project="0"
        surefire_version="0.0"
        CLONEURL=${2}
        BASEVERSION=${3}
        REVCOUNT=${4} 
        LOGDIR=${5}
        TESTCMD=${6}
        REPOFLAG=${7}
        PROJECT=${8}
        REFDIR=""
		if [[ "$1" == "auto" ]] ; then 
            surefire_version=${9}
            modules=(${10})
            version=${11}
            patch=${12}
            surefire_check=$(awk 'BEGIN{ print "'${surefire_version}'" == "0.0" }')
		fi
        echo "CLONEURL=${2}"
        echo "BASEVERSION=${3}"
        echo "REVCOUNT=${4} "
        echo "LOGDIR=${5}"
        echo "TESTCMD=${6}"
        echo "REPOFLAG=${7}"
        echo "PROJECT=${8}"
        echo "REFDIR="
		if [[ "$1" == "auto" ]] ; then 
            echo "surefire_version=${9}"
            echo "modules=(${10})"
            echo "version=${11}"
            echo "patch=${12}"
		fi
        read a
    else
        echo "**************************************************************************************************************"
        echo "ABOUT"
        echo "The script , given a clone url, and base revision to test, will clone the project and execute maven test for multiple revisions and output a collated table of executed tests, execution time etc as a csv" 
        echo "** Default branch is master"
        echo "[The scipt can be latter modified to automatically execute list of projects across multiple revisions from a file input and chart the CSV]"
        echo "**************************************************************************************************************"
        echo "Please input the script argurments "
        echo "** Please note this input shall be replaced with commandline args when automation is completed "
        echo "** Interactive input is only for demo"
        echo -e "CLONE URL : This is the git/svn project repo url  [ currently supported for git ]                : \c"
        read CLONEURL 
        echo -e "BASE COMMIT VERSION : This is the base commit revision number to start test execution                 : \c" 
        read BASEVERSION
        echo -e "NUMBER OF REVISION TO TEST                                            : \c" 
        read REVCOUNT 
        echo -e "LOGDIR: Logfile to save [default: ../logs/woEkstazi]               : \c" 
        read LOGDIR

    fi
        echo "**************************************************************************************************************"
        echo "INPUTS"
        echo "**************************************************************************************************************"
        echo "PROJECT  URL      : $CLONEURL"
        echo "BASEVERSION       : $BASEVERSION"
        echo "# of Revs to test : $REVCOUNT"
        echo "LOGDIR            : $LOGDIR"
        echo "FINAL LOGS AFTER EXECUTION WILL BE AVAILABLE UNDER $LOGDIR/woEkstazi/ directory"
        echo "**************************************************************************************************************"
        echo #
        echo #
        echo #
        echo #
        echo #
        echo #
        echo #
        echo #
        echo #
        echo #

        if [[  "$1" != "demo" ]] 
        then
            echo "Press enter to continue after verification input"
            #read a
        fi

    #clear
}


pullClone(){
    if [[ "$1" == "svn" ]]; then
        svn checkout $2 $PROJECT
    else
        git clone $2 $PROJECT
    fi

}


cloneCleanup(){
    if [[ "$1" == "svn" ]]; then
        svn cleanup
        svn status --no-ignore | grep '^[I?]' | cut -c 9- | while IFS= read -r f; do rm -rf "$f"; done
    else
        git clean -fxd
    fi
}

cloneCheckout(){
    echo "cloneCheck `pwd`"
    if [[ "$1" == "svn" ]]; then

        svn up -${2}
    else
        git checkout ${2}
    fi
}


getLastNCommits(){
    coloredEcho "FETCHING COMMIT INFORMATION FOR THE RECENT ${REVCOUNT}"
    if [[ "$1" == "svn" ]]; then
		OS=`uname -a | awk '{print $1}'`
        if [ "${OS}" ==  "Darwin" ]; then
            LASTNCOMMITS=`svn log --limit ${REVCOUNT}| perl -l40pe 's/^-+/\n/' | awk '{print $1}' | tail -r`
        else
            LASTNCOMMITS=`svn log --limit ${REVCOUNT}| perl -l40pe 's/^-+/\n/' | awk '{print $1}' | tac`
        fi
    else
		OS=`uname -a | awk '{print $1}'`
        if [ "${OS}" ==  "Darwin" ]; then
            LASTNCOMMITS=`git log -n ${REVCOUNT} --oneline | awk '{print $1}' | tail -r`
        else
            LASTNCOMMITS=`git log -n ${REVCOUNT} --oneline | awk '{print $1}' | tac`
        fi

    fi
	echo "LAST COMMITS"
	echo $LASTNCOMMITS 
	#read a
}


installSnapShots(){
    coloredEcho "INSTALLING DEPENDCIES"
    mvn install -DskipTests
}

resyncPom(){
    coloredEcho " >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> STARTING COMMIT FOR $i"
    cloneCleanup ${REPOFLAG}
    cloneCheckout ${REPOFLAG} ${i}
    for file in `find ${REFDIR} -type f -name "*pom*" | grep -v "/SHA/"`
    do
        pomPath=`echo $file | sed "s,^.*${PROJECT},,g"`
        pomDel=`echo ${pomPath} | sed -E 's,^/+,,g'  | sed 's,^/,,g'`
        if [[ -e ${pomDel} ]]; then 
            rm ${pomDel}
        fi
        repullPom ${REPOFLAG} ${pomDel} ${i}
    done
}

saveReferencePOMS(){
    if [[ "$1" == "auto" ]]    ; then
        return
    fi

    IFS=$'\n'
    for i in ${LASTNCOMMITS}
    do
    resyncPom
    echo "REFDIR is ${REFDIR}"
    #read a
    # ref dir include trunk
    # get the pom for that base revision without change 
    # compare it against the checkout revision pom 
    # if no difference, copy the modified pom of base into the folder SHA with rev name

    # COUNT_REFPOM=`find ${REFDIR} -type f -name "*pom*" | grep SHA | grep -v "BASE" | wc -l | awk '{print $1}'`
    COUNT_REFPOM=`svn ls ${REFDIR} | grep -c TESTED`

    if [[ "$COUNT_REFPOM" -gt 0 ]]; then
        coloredEcho "ALL POMS ARE ALREADY AVAILABLE!"
        #read a
        break
    else
        for file in `find ${REFDIR} -type f -name "*pom*" | grep -v "/SHA/"`
        do
            coloredEcho "FILE IS " $file
            pomPath=`echo $file | sed "s,^.*${PROJECT},,g"`
            coloredEcho "POMPATH" ${pomPath}
            #copy the changed POM in BASEVERSION to ${i}
            mkdir -p ${REFDIR}"/SHA/"${i}"/"`dirname ${pomPath}` 2>/dev/null
            # copy the BASE_VERSION SHA INTO {$i} pom path

            cp ${REFDIR}"/SHA/BASE_"${BASEVERSION}"/"${pomPath}    ${REFDIR}"/SHA/"${i}"/"${pomPath}
            echo "COPIED REF POM INTO REF DIR"
            ##read a
            diffValue=`diff ${file} ${REPODIR}/${PROJECT}/${pomPath} | grep ^[\>\<] | wc -l | awk '{print $1}'`
            #this indicates difference in pom so the base'versions modified POM cannot be used here!!!
            #read a
            echo "FILE DIFF IS ${diffValue}"
            #read a
            ##read a
            # if the new version pom is different from baseversions original pom ( without modification ) 
            # show vimdiff and save the changes under ${i} pom dif
            if [[ ${diffValue} -ne 0 ]] 
            then
                diffValue2=`diff ${REFDIR}"/SHA/BASE_"${BASEVERSION}"/"${pomPath} ${REPODIR}"/"${PROJECT}"/"${pomPath} | grep ^[\>\<] | wc -l | awk '{print $1}'`
                echo ${diffValue2}
            #read a
                if [[ ${diffValue2} -ne 0 ]] 
                then
                    vimdiff ${REFDIR}"/SHA/BASE_"${BASEVERSION}"/"${pomPath} ${REPODIR}"/"${PROJECT}"/"${pomPath} 
                    cp ${REPODIR}"/"${PROJECT}"/"${pomPath} ${REFDIR}"/SHA/"${i}"/"${pomPath}
                fi
            fi
            #read a
        done
    fi
    done
}


repullPom(){
    if [[ "$1" == "svn" ]]; then
        svn up -${3}
    else
        git checkout ${2}
    fi    
}

runTest(){
    IFS=$'\n'
    for i in $LASTNCOMMITS
    do
    # RUN TEST FOR EACH COMMIT
        coloredEcho "pwd is `pwd`"
        coloredEcho ">>>>>>>>>>>>>>>>>>>> BEGIN COMMIT : $i : " >> $LOGNAME
        coloredEcho `date` >> $LOGNAME
        cloneCleanup ${REPOFLAG}
        cloneCheckout ${REPOFLAG} ${i}
        eval ${TESTCMD} | tee -a ${LOGNAME}
        #mvn test | tee -a $LOGNAME
        coloredEcho ">>>>>>>>>>>>>>>>>>>> END OF EXECUTION FOR : $i ">> $LOGNAME
    done
}


removeEkstaziDir(){
    if [ -d ${1} ] ;then
        rm -rf ${1}
    fi
}

checkAndCloneRepo(){
    if [ -d ${REPODIR}/${PROJECT} ] 
    then
        coloredEcho "PROJECT PATH ${REPODIR}/${PROJECT} ALREADY EXISTS"
    else
        # START CLONING THE PROJECT 
        cd ${REPODIR}
        coloredEcho "  ISSUING CLONE COMMAND : clone $CLONEURL" >> ${LOGNAME}
        pullClone ${REPOFLAG} ${CLONEURL}
        mkdir -p ${REPODIR}/${PROJECT}/
     
    fi
    cd ${REPODIR}/${PROJECT}/ 

}

patchPOM(){
    echo "PATCHING POM"
	if [[ -f ${SCRIPTDIR}/${patch}  ]] ; then
    	bash -ux ${SCRIPTDIR}/${patch}
	fi
    #read a
}

#./run_ekstazi.sh -u "https://git.eclipse.org/r/p/jgit/jgit.git" -p "jgit" -v "4.2.0" -s "2.18"





autoRunWithEkstazi(){

    return 
}


copyPOMAndExecute(){
    for file in `find ${REFDIR} -type f -name "*pom*.xml" | grep "/SHA/BASE_${BASEVERSION}/"`
    do
        pomPath=`echo $file | sed "s,^.*${PROJECT}//SHA/BASE_${BASEVERSION}/,,g" | sed 's,^/,,g'`
        pomDel=`echo ${pomPath} | sed -E 's,^/+,,g'  | sed 's,^/,,g'`
        coloredEcho "CHECKING OUT POM >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        rm ${pomDel}
        repullPom ${REPOFLAG} ${pomDel} ${i}
        echo "COPIED FROM REF INTO REPO"
        cp ${REFDIR}"/SHA/"${i}"/"${pomPath}  ${REPODIR}"/"${PROJECT}"/"$pomPath
        #read a
        #read a
    done
    # coloredEcho "RUNNING $TESTCMD "
    # eval $TESTCMD | tee -a ${LOGNAME}
    # #read a
    # coloredEcho ">>>>>>>>>>>>>>>>>>>> END OF EXECUTION FOR $i " >> ${LOGNAME}
}


runWithEkstazi(){
    echo "INSIDE PROJECT FOLDER $1"
    AUTOFLAG=$2
    for i in ${LASTNCOMMITS}
    do
    # RUN TEST FOR EACH COMMIT
        coloredEcho ">>>>>>>>>>>>>>>>>>>> BEGIN COMMIT : $i : ">> ${LOGNAME}
        echo `date` >> ${LOGNAME}
        backupEkstazi
        cloneCleanup ${REPOFLAG}
        restoreEkstazi
        echo "ENTERING LOOP"
        #read a
        if [[ ! "${AUTOFLAG}" == "auto" ]]; then
            copyPOMAndExecute
            #read a
        else
            updatePOMandExecuteRun 
            #read a
        fi
        echo "ABOUT TO EXECUTE MVN TEST"
        #read a
        coloredEcho "RUNNING $TESTCMD "
        eval $TESTCMD | tee -a ${LOGNAME}
        #read a
        coloredEcho ">>>>>>>>>>>>>>>>>>>> END OF EXECUTION FOR $i " >> ${LOGNAME}
        #read a
        
    done
}
updatePOMandExecuteRun(){
    for index in "${!modules[@]}"
    do
        #read a
        echo "In project ${modules[index]},"
        cd ${modules[index]}

        if [ $surefire_check -eq "1" ]; then
            java -jar ${SCRIPTDIR}/pom_parser.jar "${REPODIR}"/"${PROJECT}" "${version}"     
        else
            java -jar ${SCRIPTDIR}/pom_parser.jar "${REPODIR}"/"${PROJECT}" "${version}" "${surefire_version}"     
        fi
        patchPOM 
    done
	echo "ENTERING THE PROJECT PATH"
    cd "${REPODIR}"/"${PROJECT}"
	pwd
	#read a
    # autoRunWithEkstazi
}

checkREFDir(){
  if [[ ${REFDIR} == "" ]]
  then
      REFDIR=$SCRIPTDIR"/../logs/pomReferenceDir/"${PROJECT}"/"
      if [[ ! -d ${REFDIR} ]]
      then
      coloredEcho "***** THIS PROGRAM REQUIRES USER TO HAVE REFERENCE POM SAVED IN THE PATH ${REFDIR} ******** "
      coloredEcho "QUITTING NOW!!!!"
      exit
      fi
  fi
}
