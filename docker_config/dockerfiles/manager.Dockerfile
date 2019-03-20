FROM ubuntu:16.04

RUN apt-get update && apt-get install -y postgresql-9.5 libssl-dev libpq-dev cpanminus build-essential

ADD ./cpanfile /cpanfile
RUN cpanm --installdeps /

ADD ./ /app

WORKDIR /app

######## END OF HEADER #########

ADD ./docker_config/entrypoints/manager.start.sh entrypoint.sh
RUN chmod +x entrypoint.sh
CMD ["./entrypoint.sh"]