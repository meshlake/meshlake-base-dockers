#!/bin/bash
set -ex

# Exist if it's not a statefulset 
if [ `hostname` =~ -([0-9]+)$ ]; then 
    echo "You must run greenplum as a stateful application using a StatefulSet.";
    exit 1; 
fi

# whoami: gpadmin

# only run on master
host=`hostname`
if [ $host = "${KUBERNETES_STATEFULSET_NAME:-greenplum}-0" ];then
   source /usr/local/greenplum-db/greenplum_path.sh
   ./setup/prepare.sh -s 1 -n 1
   gpinitsystem -a -c gpinitsystem_config
   source env.sh
   ./setup/postinstall.sh
   gpstate -s
fi