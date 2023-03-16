ARG DBT_POSTGRES_VERSION

FROM ghcr.io/dbt-labs/dbt-postgres:${DBT_POSTGRES_VERSION:-latest}

COPY install.sh /usr/local/etc/metaplane/
RUN /usr/local/etc/metaplane/install.sh

RUN mkdir -p /usr/local/etc/dbt/
COPY profiles.yml /usr/local/etc/dbt/
ENV DBT_PROFILES_DIR=/usr/local/etc/dbt/