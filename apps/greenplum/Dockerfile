FROM centos:7.9.2009

WORKDIR /app/build

RUN yum install -y wget
RUN wget -O greenplum-6.21.2.rpm https://github.com/greenplum-db/gpdb/releases/download/6.21.2/open-source-greenplum-db-6.21.2-rhel7-x86_64.rpm
RUN yum install -y greenplum-6.21.2.rpm

# RUN yum -y update && yum clean all 

# RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
# RUN groupadd gpadmin
# RUN useradd gpadmin -g gpadmin
# RUN echo gpadmin | passwd gpadmin --stdin