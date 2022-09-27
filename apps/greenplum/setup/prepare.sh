#!/bin/bash

set -e

source /usr/local/greenplum-db/greenplum_path.sh

# Verify if GPHOME is set
if [ -z ${GPHOME+x} ]; then 
    echo "GPHOME is unset";
    exit 1; 
fi

USER=`whoami`
GROUP=`id -gn`
MASTERHOST=`hostname`
PASSWORD=${PASSWORD:-gpadmin}
SEG_PREFIX=${KUBERNETES_STATEFULSET_NAME:-greenplum}-
KUBERNETES_SERVICE_NAME=${KUBERNETES_SERVICE_NAME:-greenplum}
SEG_HOSTNUM=0 # 0 means master only
SEG_NUMPERHOST=1
VERBOSE=0
GPINIT_ENABLED=0

CURDIR=$(cd $(dirname $0); pwd)
PREFIX=$(pwd)

CONF_GENERATED_DIR=/app/greenplum/generated
DATA_BASE_DIR=/app/greenplum/data
mkdir -p $CONF_GENERATED_DIR $DATA_BASE_DIR

CONFIGTEMPLATE=$CURDIR/gpinitsystem_config_template
GP_INIT_CONFIG_FILE=$CONF_GENERATED_DIR/gpinitsystem_config
GP_ENV_CONFIG_FILE=$CONF_GENERATED_DIR/env.sh
HOSTFILE_EXKEYS=$CONF_GENERATED_DIR/hostfile_exkeys
HOSTFILE_GPINITSYSTEM=$CONF_GENERATED_DIR/hostfile_gpinitsystem

MASTER_DATA_BASE_DIR=$DATA_BASE_DIR/master
MASTER_STANDBY_DATA_BASE_DIR=$DATA_BASE_DIR/mirror
PRIMARY_SEGMENT_BASE_DIR=$DATA_BASE_DIR/segments

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
    echo "-i: intialize greenplum, default is off"
}

function checkInt()
{
    expr $1 + 0 &>/dev/null
    if [ $? -ne 0 ]; then
        echo "$0: $OPTARG is not a number." >&2
        exit 1
    fi
}

while getopts :hvim:n:s: arg
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
        i) GPINIT_ENABLED=1
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

function create_gpinitsystem_config() {
    SEGDATASTR=""
    for i in $(seq 1 $SEG_NUMPERHOST);  do 
        SEGDATASTR="$SEGDATASTR  $PRIMARY_SEGMENT_BASE_DIR"
    done

    sed -e "s/%%PORT_BASE%%/$PORT_BASE/g; s|%%SEGDATASTR%%|$SEGDATASTR|g;" \
        -e "s|%%MASTER_DATA_BASE_DIR%%|$MASTER_DATA_BASE_DIR|g;" \
        -e "s|%%MASTER_STANDBY_DATA_BASE_DIR%%|$MASTER_STANDBY_DATA_BASE_DIR|g;" \
        -e "s|%%MASTERHOST%%|$MASTERHOST.$KUBERNETES_SERVICE_NAME|g; s/%%MASTER_PORT%%/$MASTER_PORT/g;" \
        -e "s/%%MIRROR_PORT_BASE%%/$MIRROR_PORT_BASE/g;" \
        -e "s/%%REPLICATION_PORT_BASE%%/$REPLICATION_PORT_BASE/g;" \
        -e "s/%%MIRROR_REPLICATION_PORT_BASE%%/$MIRROR_REPLICATION_PORT_BASE/g;" \
        -e "s/%%STARTDB%%/$STARTDB/g;" \
        -e "s|%%HOSTFILE_GPINITSYSTEM%%|$HOSTFILE_GPINITSYSTEM|g;" $CONFIGTEMPLATE >$GP_INIT_CONFIG_FILE
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
    cat >$GP_ENV_CONFIG_FILE <<-EOD
        source $GPHOME/greenplum_path.sh
        SRCDIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" && pwd )"
        export MASTER_DATA_DIRECTORY=$MASTER_DATA_BASE_DIR/gpseg-1
        export USER=$USER
        export PGPORT=$MASTER_PORT
        export PGHOST=$MASTERHOST
        export PGDATABASE=$STARTDB
EOD
}

function enable_passwordless_ssh() {
    # checking if all host are reachable
    # nc -z greenplum-0.greenplum 22
    cat $HOSTFILE_EXKEYS | xargs -I{} sh -c 'ssh-keyscan -H {} >> ~/.ssh/known_hosts'
    cat $HOSTFILE_EXKEYS | xargs -I{} sh -c "SSHPASS=$PASSWORD sshpass -e ssh-copy-id {}"
    gpssh-exkeys -f $HOSTFILE_EXKEYS
    gpssh -u $USER -f $HOSTFILE_EXKEYS -e 'ls -l /usr/local/greenplum-db/ 1>/dev/null'
}

function reset_data_directories() {
    for host in `cat $HOSTFILE_EXKEYS`; do
        gpssh -u $USER -h $host -e "sudo chown $USER:$GROUP $DATA_BASE_DIR"
    done
    for host in `cat $HOSTFILE_EXKEYS`; do
        gpssh -u $USER -h $host -e "rm -rf $MASTER_DATA_BASE_DIR $MASTER_STANDBY_DATA_BASE_DIR $PRIMARY_SEGMENT_BASE_DIR"
    done
    for host in `cat $HOSTFILE_EXKEYS`; do
        gpssh -u $USER -h $host -e "mkdir -p $MASTER_DATA_BASE_DIR $MASTER_STANDBY_DATA_BASE_DIR $PRIMARY_SEGMENT_BASE_DIR"
    done
}

function repair_data_directories() {
    for host in `cat $HOSTFILE_EXKEYS`; do
        gpssh -u $USER -h $host -e "sudo chown $USER:$GROUP $DATA_BASE_DIR"
    done
}

function init_gp() {
    gpinitsystem --ignore-warnings -a -c $GP_INIT_CONFIG_FILE
}

function init() {
    if [ $GPINIT_ENABLED -ne 1 ];then
        echo "Repair the greenplum system..."
        repair_data_directories
        source $GP_ENV_CONFIG_FILE
        if `gpstate -b -q`; then 
            gpstop -u
        else
            gpstart -a
        fi
        echo -e "\nGreenplum Repair Completed!\n"
    else
        echo "Start to intialize greenplum..."
        reset_data_directories
        init_gp
        echo -e "\nGreenplum Intialization Completed!\n"
        post_init
    fi
    gpstate -s
    echo "source $GP_ENV_CONFIG_FILE" >> ~/.bashrc
}

function post_init() {
    source $GP_ENV_CONFIG_FILE
    echo "host all gpadmin 0.0.0.0/0 trust"  >> $MASTER_DATA_DIRECTORY/pg_hba.conf
    gpstop -u
}

create_gpinitsystem_config
create_hostfile_exkeys
create_hostfile_gpinitsystem
create_env_script

enable_passwordless_ssh
init

echo -e "\nGreenplum Preparation Completed!\n"