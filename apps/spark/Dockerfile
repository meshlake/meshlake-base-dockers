ARG BITNAMI_SPARK_VERSION

FROM maven:3.6.3-openjdk-11 as builder

WORKDIR /opt/meshlake/builder/extra_spark_jars
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:copy -Dartifact=org.postgresql:postgresql:42.5.0 -DoutputDirectory=.
# RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:copy -Dartifact=org.apache.hudi:hudi-spark3.3-bundle_2.12:0.12.1 -DoutputDirectory=.
# RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:copy -Dartifact=org.apache.hudi:hudi-utilities-bundle_2.12:0.12.1 -DoutputDirectory=.
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:copy -Dartifact=org.apache.iceberg:iceberg-spark-runtime-3.3_2.12:1.1.0 -DoutputDirectory=.
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:copy -Dartifact=software.amazon.awssdk:url-connection-client:2.17.257 -DoutputDirectory=.
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:copy -Dartifact=software.amazon.awssdk:bundle:2.17.257 -DoutputDirectory=.

FROM bitnami/spark:${BITNAMI_SPARK_VERSION:-latest}

USER root
RUN useradd spark -u 1001 -r -m -g root
RUN echo "spark:spark" | chpasswd
# RUN echo "spark ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/spark

RUN mkdir -p /opt/bitnami/spark/extra/jars && chown -R "spark:root" /opt/bitnami/spark/extra && chmod -R 775 /opt/bitnami/spark/extra
COPY --from=builder --chown=spark:root /opt/meshlake/builder/extra_spark_jars /opt/bitnami/spark/extra/jars
RUN chmod -R 664 /opt/bitnami/spark/extra/jars/*.jar
RUN ls -al /opt/bitnami/spark/extra/jars/

USER spark