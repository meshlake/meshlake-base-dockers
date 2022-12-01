ARG BITNAMI_SPARK_VERSION

FROM maven:3.6.3-openjdk-11 as builder

WORKDIR /opt/meshlake/builder/extra_spark_jars
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:copy \
    -Dartifact=org.postgresql:postgresql:42.5.0 \
    -DoutputDirectory=.

FROM bitnami/spark:${BITNAMI_SPARK_VERSION:-latest}

USER root
RUN useradd spark -u 1001 -r -m -g root
RUN echo "spark:spark" | chpasswd
# RUN echo "spark ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/spark
USER spark


COPY --from=builder --chown=spark:root /opt/meshlake/builder/extra_spark_jars /opt/bitnami/spark/jars/