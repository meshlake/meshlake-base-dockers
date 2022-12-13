# The Meshlake Containers Library

Applications, provided by Meshlake, containerized and ready to launch for production use.

## Support List

- [x] LinkedIn Datahub
- [x] Alibaba DataX
- [x] Greenplum
- [x] Spark
- [x] Airflow
- [x] Kafka Connect

## Release Tags & Features

### LinkedIn Datahub

#### `datahub-ingestion:jdk11`

- Tags: `meshlake/datahub-ingestion:jdk11`, `${{ secrets.MESHLAKE_HARBOR_REGISTRY }}/linkedin/datahub-ingestion:jdk11`
- Release date: `2022-09-28`

### Alibaba DataX

#### `datax:0.0.1`

- Tags: `meshlake/datax:0.0.1`,`${{ secrets.MESHLAKE_HARBOR_REGISTRY }}/alibaba/datax:0.0.1`
- Release date: `2022-09-28`

### Greenplum

#### `greenplum-kubernetes:6.21.2`

- Tags: `meshlake/greenplum-kubernetes:6.21.2`,`${{ secrets.MESHLAKE_HARBOR_REGISTRY }}/dockerio/greenplum-kubernetes:6.21.2`
- Release date: `2022-09-28`

### Apache Spark

#### `spark:3.3.0-debian-11-r42`

Based on `bitnami/spark:3.3.0-debian-11-r42`, including the following extra features:

- Introduce user `spark` with uid `1001`, as bitnami containers are [non-root](https://docs.bitnami.com/tutorials/running-non-root-containers-on-openshift) and it causes STS failed to start.
- Pre-install jars into spark classpath as which can't set up properly with STS through `--packages`:
  - `org.apache.hudi:hudi-spark3.1-bundle_2.12:0.12.1`

### Apache Airflow

Based on `apache/airflow:2.3.0`, including the following extra features:

- Extra built-in providers:
  - `apache-airflow-providers-apache-spark`

### Kafka Connect (Confluent)

Based on `confluentinc/cp-kafka-connect:7.3.0`, including the following extra features:

- Extra built-in connectors:
  - `confluentinc/kafka-connect-jdbc:10.6.0`
  - `confluentinc/kafka-connect-datagen:0.6.0`
