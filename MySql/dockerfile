FROM blueline/alpine

MAINTAINER blueline

RUN apk --update add mariadb mariadb-client pwgen && \
rm -f /var/cache/apk/* &&\
mkdir -p /scripts/pre-exec.d && \
mkdir -p /scripts/pre-init.d && \
chmod -R 755 /scripts

ADD run.sh /scripts/run.sh

EXPOSE 3306

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/scripts/run.sh"]