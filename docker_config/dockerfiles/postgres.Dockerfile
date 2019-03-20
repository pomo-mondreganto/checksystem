FROM postgres:9.5

ADD ./docker_config/entrypoints/postgres.start.sh /docker-entrypoint-initdb.d/custom_init.sh
