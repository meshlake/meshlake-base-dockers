ARG CONFLUENT_PLATFORM_VERSION

FROM confluentinc/cp-kafka-connect:${CONFLUENT_PLATFORM_VERSION:-latest}

RUN confluent-hub install --no-prompt confluentinc/kafka-connect-datagen:latest
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.6.0
RUN confluent-hub install --no-prompt debezium/debezium-connector-mysql:2.0.1
