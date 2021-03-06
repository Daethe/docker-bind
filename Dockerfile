FROM alpine:3.7

LABEL maintainer="marc.proux@piestr.fr"

ENV BIND_USER=bind
ENV BIND_VERSION=9.11.3
ENV DATA_DIR=/data
ENV WEBMIN_VERSION=1.900
ENV WEBMIN_USERNAME=admin
ENV WEBMIN_PASSWORD=password

RUN cd /data
COPY webmin-setup /data/webmin-setup
RUN sed -i -e "s/\${WEBMIN_USERNAME}/${WEBMIN_USERNAME}/g" /data/webmin-setup
RUN sed -i -e "s/\${WEBMIN_PASSWORD}/${WEBMIN_PASSWORD}/g" /data/webmin-setup
COPY webmin-services /data/webmin-services

RUN apk add perl
RUN wget http://prdownloads.sourceforge.net/webadmin/webmin-${WEBMIN_VERSION}.tar.gz
RUN gunzip webmin-${WEBMIN_VERSION}.tar.gz
RUN tar xvf webmin-${WEBMIN_VERSION}.tar
RUN mv webmin-${WEBMIN_VERSION} webmin
RUN cat /data/webmin-setup | ./setup.sh
RUN cat /data/webmin-services | tee /etc/init.d/webmin
RUN chmod a+x /etc/init.d/webmin
RUN rc-update add webmin
RUN rc-service webmin start

RUN apk update
RUN apk upgrade
RUN apk add bind=1:${BIND_VERSION}* bind9-host=1:${BIND_VERSION}* dnsutils

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp 10000/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/named"]
