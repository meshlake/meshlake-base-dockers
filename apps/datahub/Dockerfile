FROM linkedin/datahub-ingestion:head

LABEL maintainer="Ding Wei devops@meshlake.com"

USER root
RUN apt-get update && apt-get install sudo -y
RUN echo "datahub ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers
ENV USERNAME datahub
RUN addgroup --system datahub && adduser --system datahub --ingroup datahub --ingroup sudo --disabled-password
RUN bash -c 'echo $USERNAME:datahub | chpasswd'

USER datahub
RUN  sudo apt-get update && sudo apt-get install -y openjdk-11-jdk

ENTRYPOINT [ "datahub" ]