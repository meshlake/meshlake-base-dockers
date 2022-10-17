ARG BITNAMI_SPARK_VERSION=3.3.0-debian-11-r42

FROM bitnami/spark:${BITNAMI_SPARK_VERSION}

USER root
RUN useradd spark -u 1001 -r -m -g root
RUN echo "spark:spark" | chpasswd
# RUN echo "spark ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/spark
USER spark