#!/bin/bash

set -x

source /usr/local/greenplum-db/greenplum_path.sh

# Verify if GPHOME is set
if [ -z ${GPHOME+x} ]; then 
    echo "GPHOME is unset";
    exit 1; 
fi

USER=`whoami`
MASTERHOST=`hostname`
SEG_PREFIX=${KUBERNETES_STATEFULSET_NAME:-greenplum}-
KUBERNETES_SERVICE_NAME=${KUBERNETES_SERVICE_NAME:-greenplum}
SEG_HOSTNUM=0 # 0 means master only
SEG_NUMPERHOST=1
VERBOSE=0

CURDIR=$(cd $(dirname $0); pwd)
PREFIX=$(pwd)
CONFIGFILE=$PREFIX/gpinitsystem_config
CONFIGTEMPLATE=$CURDIR/gpinitsystem_config_template
HOSTFILE_EXKEYS=$HOME/hostfile_exkeys
HOSTFILE_GPINITSYSTEM=$HOME/hostfile_gpinitsystem

MASTER_DATA_DIRECTORY=$PREFIX/master
MASTER_STANDBY_DATA_DIRECTORY=$PREFIX/mirror
DATA_DIRECTORY=$PREFIX/data

PORT_BASE=10000
MASTER_PORT=5432
MIRROR_PORT_BASE=30000
REPLICATION_PORT_BASE=31000
MIRROR_REPLICATION_PORT_BASE=32000
STARTDB=default

function help()
{
    echo "help:"
    echo "-v: verbose"
    echo "-n number_of_segments_per_host"
    echo "-s number_of_host: default is 0, means same host as master"
}

function checkInt()
{
    expr $1 + 0 &>/dev/null
    if [ $? -ne 0 ]; then
        echo "$0: $OPTARG is not a number." >&2
        exit 1
    fi
}

while getopts :hvm:n:s: arg
do
    case $arg in
        h) help
	        exit 1
	        ;;
	
        m) MASTER="$OPTARG"
	        checkInt $MASTER
            ;;
	
        n) SEG_NUMPERHOST="$OPTARG"
	        checkInt $SEG_NUMPERHOST
            ;;
        s) SEG_HOSTNUM="$OPTARG"
            checkInt $SEG_HOSTNUM
            ;;
        :) echo "$0: Must supply an argument to -$OPTARG." >&2
	        help
            exit 1
            ;;
        \?) echo "Invalid option -$OPTARG ignored." >&2
	        help
            ;;
    esac
done

function reset_data_directories() {
    gpssh -u $USER -f $HOSTFILE_EXKEYS -e "rm -rf $MASTER_DATA_DIRECTORY $DATA_DIRECTORY $MASTER_STANDBY_DATA_DIRECTORY"
    gpssh -u $USER -f $HOSTFILE_EXKEYS -e "mkdir -p $MASTER_DATA_DIRECTORY $DATA_DIRECTORY $MASTER_STANDBY_DATA_DIRECTORY"
}

function create_gpinitsystem_config() {
    SEGDATASTR=""
    for i in $(seq 1 $SEG_NUMPERHOST);  do 
        SEGDATASTR="$SEGDATASTR  $PREFIX/data"
    done

    sed -e "s/%%PORT_BASE%%/$PORT_BASE/g; s|%%PREFIX%%|$PREFIX|g; s|%%SEGDATASTR%%|$SEGDATASTR|g;" \
        -e "s/%%MASTERHOST%%/$MASTERHOST.$KUBERNETES_SERVICE_NAME/g; s/%%MASTER_PORT%%/$MASTER_PORT/g;" \
        -e "s/%%MIRROR_PORT_BASE%%/$MIRROR_PORT_BASE/g;" \
        -e "s/%%REPLICATION_PORT_BASE%%/$REPLICATION_PORT_BASE/g;" \
        -e "s/%%MIRROR_REPLICATION_PORT_BASE%%/$MIRROR_REPLICATION_PORT_BASE/g;" \
        -e "s/%%STARTDB%%/$STARTDB/g;" \
        -e "s/%%HOSTFILE_GPINITSYSTEM%%/$HOSTFILE_GPINITSYSTEM/g;" $CONFIGTEMPLATE >$CONFIGFILE
}

function create_hostfile_exkeys() {
    >$HOSTFILE_EXKEYS
    if [ $SEG_HOSTNUM -eq 0 ];then
        echo $MASTERHOST.$KUBERNETES_SERVICE_NAME >  $HOSTFILE_EXKEYS 
    else
        echo $MASTERHOST.$KUBERNETES_SERVICE_NAME >  $HOSTFILE_EXKEYS
        for i in $(seq 1 $SEG_HOSTNUM); do
        echo $SEG_PREFIX$i.$KUBERNETES_SERVICE_NAME >> $HOSTFILE_EXKEYS
        done
    fi
}

function create_hostfile_gpinitsystem() {
    >$HOSTFILE_GPINITSYSTEM
    if [ $SEG_HOSTNUM -eq 0 ];then
        echo $MASTERHOST.$KUBERNETES_SERVICE_NAME >  $HOSTFILE_GPINITSYSTEM 
    else
        for i in $(seq 1 $SEG_HOSTNUM); do
        echo $SEG_PREFIX$i.$KUBERNETES_SERVICE_NAME >> $HOSTFILE_GPINITSYSTEM
        done
    fi
}

function create_env_script() {
    cat >$PREFIX/env.sh <<-EOD
        source $GPHOME/greenplum_path.sh
        SRCDIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" && pwd )"
        export MASTER_DATA_DIRECTORY=\$SRCDIR/master/gpseg-1
        export PGPORT=$MASTER_PORT
        export PGHOST=$MASTER
        export PGDATABASE=$STARTDB
EOD
}

function enable_passwordless_ssh() {
    cat $HOSTFILE_EXKEYS | xargs -I{} sh -c 'ssh-keyscan -H {} >> ~/.ssh/known_hosts'
    cat $HOSTFILE_EXKEYS | xargs -I{} sh -c 'SSHPASS=gpadmin sshpass -e ssh-copy-id {}'
    gpssh-exkeys -f $HOSTFILE_EXKEYS
    gpssh -u $USER -f $HOSTFILE_EXKEYS -e 'ls -l /usr/local/greenplum-db/'
}

create_gpinitsystem_config
create_hostfile_exkeys
create_hostfile_gpinitsystem
create_env_script

enable_passwordless_ssh
reset_data_directories