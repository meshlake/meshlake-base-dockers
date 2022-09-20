FROM centos:7.9.2009

RUN yum -y update && yum clean all 

WORKDIR /app/build
RUN yum install -y wget
RUN wget -O greenplum-6.21.2.rpm https://github.com/greenplum-db/gpdb/releases/download/6.21.2/open-source-greenplum-db-6.21.2-rhel7-x86_64.rpm
RUN yum install -y greenplum-6.21.2.rpm 
RUN rm -rf greenplum-6.21.2.rpm

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN groupadd gpadmin
RUN useradd gpadmin -g gpadmin
RUN echo gpadmin | passwd gpadmin --stdin
RUN chown -R gpadmin:gpadmin /usr/local/greenplum*
RUN chgrp -R gpadmin /usr/local/greenplum*

USER gpadmin
WORKDIR /app/greenplum
COPY --chown=gpadmin:gpadmin ./setup /app/greenplum/setup
COPY --chown=gpadmin:gpadmin ./init.sh /app/greenplum/init.sh