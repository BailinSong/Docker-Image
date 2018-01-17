FROM blueline/alpine

MAINTAINER blueline

ADD run.sh /scripts/run.sh
RUN apk --update add mariadb mariadb-client pwgen && \
rm -f /var/cache/apk/* &&\
mkdir -p /scripts/pre-exec.d && \
mkdir -p /scripts/pre-init.d && \
chmod -R 755 /scripts

EXPOSE 3306

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/scripts/run.sh"]