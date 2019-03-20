FROM ubuntu:16.04

RUN apt-get update && apt-get install -y postgresql-9.5 libssl-dev libpq-dev cpanminus build-essential

ADD ./cpanfile /cpanfile
RUN cpanm --installdeps /

ADD ./ /app

WORKDIR /app

######## END OF HEADER #########

ADD ./docker_config/entrypoints/initializer.sh initializer.sh
RUN chmod +x initializer.sh
CMD ["./initializer.sh"]
