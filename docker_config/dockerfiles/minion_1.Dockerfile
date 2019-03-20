FROM ubuntu:16.04

RUN apt-get update && apt-get install -y postgresql-9.5 libssl-dev libpq-dev cpanminus build-essential

ADD ./cpanfile /cpanfile
RUN cpanm --installdeps /

RUN apt-get update && apt-get install -y python3-dev python3-pip

ADD ./ /app

WORKDIR /app

######## END OF HEADER #########

ADD ./checkers /checkers
RUN pip3 install -r /checkers/requirements.txt

######## END OF MINION SUBHEADER #########

ADD ./docker_config/entrypoints/minion_1.start.sh entrypoint.sh
RUN chmod +x entrypoint.sh
CMD ["./entrypoint.sh"]