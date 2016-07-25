#!/bin/bash

##########################################
#Simple script to cleanup project servers#
##########################################


################
#get free space#
################

get_free_space(){
  FREE_SPACE=`df -BG | awk '$6 == "/home" || $5 == "/home"  {print $0}' `
  if [ -z "$FREE_SPACE" ] ; then
     FREE_SPACE=`df -BG | awk '$5 == "/"  || $6 == "/"  {print $0}' `
  fi
FREE_SPACE=`echo $FREE_SPACE | awk 'NF == 5 {print $3} NF == 6 {print $4}' | sed 's/\([0-9]*\)G/\1/g' `
  echo $FREE_SPACE
	}

#################
#set Environment#
#################

export HOST=$(echo $HOSTNAME |cut -d "." -f 1)
echo "Machine host name is...$HOST"
export APP_HOME=/opt/IBM/WebSphere/AppServer/profiles/AppSrv01
export DMGR_HOME=/opt/IBM/WebSphere/AppServer/profiles/dmgr
export RM_ARGS="javacore* Snap* *.dmp *.phd"
export export TEMP_LOG=/tmp/cleanup.log
export RETAIN_DIRS=1

get_free_space

############################
#Remove the offending files#
############################ 

cd $APP_HOME
 export FILES=$(ls $RM_ARGS 2> /dev/null |wc -l)
  echo "Number of file to delete ...**$FILES**"

 if [ ${FILES} -gt 0 ];then
	echo "Files exist removing...**Standby**"
	  rm -f $RM_ARGS 2> /dev/null
       else 
	    echo "No Java_Heap files to delete moving on..."
 fi	
	
##################
#Cleanup of wstmp#
##################
	
echo "Cleaning files in WStemp folder older then 60min"
echo "##################################################################"
echo "#If you are currently deploying, your deploy will not be effected#"
echo "##################################################################"

 if [ $(find $DMGR_HOME/wstemp/* -type f  -mmin +59 |wc -l) -gt 1 ]; then
   find $DMGR_HOME/wstemp/* -type f  -mmin +59 |xargs --verbose rm -Rf
    echo "Cleared WSTemp moving on..."
     else
      echo "No old files to delete moving on"
 fi

get_free_space     
exit
