FROM centos:7.9.2009

RUN yum -y update && yum -y install openssh-server passwd bash sudo && yum clean all 
RUN mkdir -p /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

WORKDIR /app/build
RUN yum install -y wget
RUN wget -O greenplum-6.21.2.rpm https://github.com/greenplum-db/gpdb/releases/download/6.21.2/open-source-greenplum-db-6.21.2-rhel7-x86_64.rpm
RUN yum install -y greenplum-6.21.2.rpm 
RUN rm -rf greenplum-6.21.2.rpm

RUN useradd gpadmin -g wheel
RUN echo gpadmin | passwd gpadmin --stdin
RUN chown -R gpadmin:wheel /usr/local/greenplum*
RUN chgrp -R wheel /usr/local/greenplum*

USER gpadmin
WORKDIR /app/greenplum
COPY --chown=gpadmin:wheel ./setup /app/greenplum/setup
COPY --chown=gpadmin:wheel ./init.sh /app/greenplum/init.sh

CMD [ "/usr/sbin/sshd", "-D" ]