#!/bin/bash
set -e

# Exist if it's not a statefulset 
if [ `hostname` =~ -([0-9]+)$ ]; then 
    echo "You must run greenplum as a stateful application using a StatefulSet.";
    exit 1; 
fi

# whoami: gpadmin

# only run on master
host=`hostname`
if [ $host = "${KUBERNETES_STATEFULSET_NAME:-greenplum}-0" ];then
    # For non first time start
    ./setup/prepare.sh -s 1 -n 1

    # For first time intialization
    # ./setup/prepare.sh -s 1 -n 1 -i
fi