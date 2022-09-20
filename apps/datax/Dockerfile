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

WORKDIR /app/datax
# ***Separate copy to leverage docker layered architecture***
COPY ./target/[^plugin]* /app/datax/
RUN mkdir -p /app/datax/plugin/reader && mkdir -p /app/datax/plugin/writer

COPY ./target/plugin/reader/cassandrareader /app/datax/plugin/reader/
COPY ./target/plugin/reader/drdsreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/ftpreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/gdbreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/hbase094xreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/hbase11xreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/hbase11xsqlreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/hbase20xsqlreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/hdfsreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/kingbaseesreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/mongodbreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/mysqlreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/oceanbasev10reader /app/datax/plugin/reader/
COPY ./target/plugin/reader/odpsreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/opentsdbreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/oraclereader /app/datax/plugin/reader/
COPY ./target/plugin/reader/ossreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/otsreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/otsstreamreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/postgresqlreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/rdbmsreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/sqlserverreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/streamreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/tdenginereader /app/datax/plugin/reader/
COPY ./target/plugin/reader/tsdbreader /app/datax/plugin/reader/
COPY ./target/plugin/reader/txtfilereader /app/datax/plugin/reader/

COPY ./target/plugin/writer/adbpgwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/adswriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/cassandrawriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/clickhousewriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/drdswriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/elasticsearchwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/ftpwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/gdbwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/hbase094xwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/hbase11xsqlwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/hbase11xwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/hbase20xsqlwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/hdfswriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/hologresjdbcwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/kingbaseeswriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/kuduwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/mongodbwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/mysqlwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/oceanbasev10writer /app/datax/plugin/writer/
COPY ./target/plugin/writer/ocswriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/odpswriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/oraclewriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/osswriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/otswriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/postgresqlwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/rdbmswriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/sqlserverwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/starrockswriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/streamwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/tdenginewriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/tsdbwriter /app/datax/plugin/writer/
COPY ./target/plugin/writer/txtfilewriter /app/datax/plugin/writer/

ENTRYPOINT ["/usr/bin/python", "/app/datax/bin/datax.py"]
CMD [""]