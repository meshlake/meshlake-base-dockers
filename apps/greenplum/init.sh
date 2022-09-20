#!/bin/bash

# whoami: gpadmin

# only run on master
host=`hostname`
if [ $host = "${KUBERNETES_STATEFULSET_NAME:-greenplum}-0" ];then
   source /usr/local/greenplum-db/greenplum_path.sh
   ./setup/prepare.sh -s 2 -n 2
   gpinitsystem -a -c gpinitsystem_config
   source env.sh
   ./setup/postinstall.sh
   gpstate -s
fi