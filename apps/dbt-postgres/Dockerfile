ARG DBT_POSTGRES_VERSION

FROM ghcr.io/dbt-labs/dbt-postgres:${DBT_POSTGRES_VERSION:-latest}

RUN apt-get update -y && apt-get install curl -y
RUN /bin/bash -c "$(curl -fsSL https://cli.metaplane.dev/install.sh)"

RUN mkdir -p /usr/local/etc/dbt/
COPY profiles.yml /usr/local/etc/dbt/
ENV DBT_PROFILES_DIR=/usr/local/etc/dbt/