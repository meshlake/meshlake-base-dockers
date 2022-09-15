# FROM maven:3.6.3-openjdk-11 AS builder

# SHELL ["/bin/bash", "-c"]

# WORKDIR /usr/local/
# RUN git clone https://github.com/meshlake/DataX.git
# WORKDIR /usr/local/DataX/
# RUN sed -i "s#<module>oscarwriter</module>#<!-- <module>oscarwriter</module> -->#" pom.xml
# RUN ls -al
# RUN mvn -U clean package assembly:assembly -Dmaven.test.skip=true

FROM maven:3.6.3-openjdk-11

SHELL ["/bin/bash", "-c"]

# Maintainer
LABEL maintainer="Ding devops@meshlake.com"

USER root

# Set Asia/Shanghai as default timezone
ENV TZ Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime > /etc/timezone

# Set permanent environment variables
RUN sed -i "2 a export JAVA_HOME=/usr/local/openjdk-11" /etc/profile
RUN sed -i "3 a export PATH=\$PATH:\$JAVA_HOME/bin" /etc/profile
# RUN sed -i "4 a export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" /etc/profile
RUN sed -i "5 a export MAVEN_HOME=/usr/share/maven" /etc/profile
RUN sed -i "6 a export PATH=\$PATH:\$MAVEN_HOME/bin" /etc/profile
RUN source /etc/profile
RUN sed -i '1 a source /etc/profile' ~/.bashrc
RUN source ~/.bashrc

# Set dynamic environment variables
ENV JAVA_HOME /usr/local/openjdk-11
ENV PATH $PATH:$JAVA_HOME/bin
# ENV CLASSPATH .:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV MAVEN_HOME /usr/share/maven
ENV PATH $PATH:$MAVEN_HOME/bin

WORKDIR /app
# COPY --from=builder /usr/local/DataX/target/datax.tar.gz /app/
COPY datax.tar.gz /app/
RUN tar -xvf datax.tar.gz -C /app
RUN rm -rf /app/datax.tar.gz
WORKDIR /app/datax

ENTRYPOINT ["/usr/bin/python", "/app/datax/bin/datax.py"]
CMD [""]