FROM jasonrivers/nagios:latest

MAINTAINER Technik Service Whitesheep <support@ts-ws.de>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y bash libsasl2-modules apt-utils htop


# Setup HTTPS
COPY ./ssl/ssl.conf /etc/apache2/sites-available/ssl.conf
COPY ./ssl/apache-selfsigned.crt /etc/apache2/certificate/apache-selfsigned.crt
COPY ./ssl/apache-selfsigned.key /etc/apache2/certificate/apache-selfsigned.key

RUN a2enmod ssl && \
    a2ensite ssl.conf


# Setup Postfix
COPY ./postfix/sasl_password /etc/postfix/sasl_password
COPY ./postfix/sender_canonical /etc/postfix/sender_canonical

RUN postmap hash:/etc/postfix/sasl_password && \
    postmap /etc/postfix/sender_canonical


# Python for Telegram
#RUN /usr/bin/pip --version && \
#    /usr/bin/pip install --upgrade pip
#RUN /usr/local/bin/pip --version && \
#    /usr/local/bin/pip install apprise


# Set Timezone
RUN cp /usr/share/zoneinfo/Europe/Berlin /usr/share/zoneinfo/Zulu && \
    dpkg-reconfigure tzdata


#apt cleanup
RUN apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/apt


EXPOSE 8444
EXPOSE 8080

CMD [ "/usr/local/bin/start_nagios" ]
