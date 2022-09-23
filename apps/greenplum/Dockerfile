FROM centos:7.9.2009

ARG GREENPLUM_VERSION=6.21.2
RUN yum update -y && yum install openssh-server passwd bash sudo sshpass rsync -y && yum clean all 
RUN mkdir -p /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

RUN echo "RemoveIPC=no" >> /etc/systemd/logind.conf
RUN service systemd-logind restart

WORKDIR /app/build
RUN yum install -y wget
RUN wget -O greenplum-${GREENPLUM_VERSION}.rpm https://github.com/greenplum-db/gpdb/releases/download/${GREENPLUM_VERSION}/open-source-greenplum-db-${GREENPLUM_VERSION}-rhel7-x86_64.rpm
RUN yum install -y greenplum-${GREENPLUM_VERSION}.rpm 
RUN rm -rf greenplum-${GREENPLUM_VERSION}.rpm

RUN groupadd gpadmin
RUN useradd gpadmin -r -m -g gpadmin
RUN echo gpadmin | passwd gpadmin --stdin
RUN echo "gpadmin ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/gpadmin
RUN usermod -aG wheel gpadmin

RUN chown -R gpadmin:gpadmin /usr/local/greenplum*
RUN chgrp -R gpadmin /usr/local/greenplum*

USER gpadmin
RUN ssh-keygen -t rsa -b 4096 -f /home/gpadmin/.ssh/id_rsa -N ''

WORKDIR /app/greenplum
COPY --chown=gpadmin:gpadmin ./setup /app/greenplum/setup
COPY --chown=gpadmin:gpadmin ./init.sh /app/greenplum/init.sh

CMD [ "sudo", "/usr/sbin/sshd", "-D" ]