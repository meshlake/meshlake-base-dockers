#!/bin/bash
set -xe

source /usr/local/greenplum-db/greenplum_path.sh

# Verify if GPHOME is set
if [ -z ${GPHOME+x} ]; then echo "GPHOME is unset"; exit 1; fi
if [ -z ${MASTER_DATA_DIRECTORY+x} ]; then echo "MASTER_DATA_DIRECTORY is unset"; exit 1; fi

PREFIX=$(pwd)

echo "host all gpadmin 0.0.0.0/0 trust"  >> $MASTER_DATA_DIRECTORY/pg_hba.conf
gpstop -u
echo "source ${PREFIX}/generated/env.sh" >> /home/gpadmin/.bashrc
gpstate -s

echo "Greenplum Post-validate Completed!"