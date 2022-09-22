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
    # checking if all host are reachable
    # nc -z greenplum-0.greenplum 22
    cat ~/hostfile_exkeys | xargs -I{} sh -c 'ssh-keyscan -H {} >> ~/.ssh/known_hosts'
    cat ~/hostfile_exkeys | xargs -I{} sh -c 'SSHPASS=gpadmin sshpass -e ssh-copy-id {}'
    gpinitsystem -a -c gpinitsystem_config
    source env.sh
    ./setup/postinstall.sh
    gpstate -s
fi