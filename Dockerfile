FROM ubuntu:latest

WORKDIR /etc/mail

RUN set -e && \
 apt-get update && \
 apt-get install -y sendmail

COPY sendmail.mc /etc/mail/sendmail.mc

RUN m4 sendmail.mc > sendmail.cf && \
 echo "Connect:172 RELAY" >> access && \
 echo "Connect:10 RELAY" >> access && \
 make

EXPOSE 25

CMD /usr/lib/sendmail -bD -X /proc/self/fd/1

RUN apk update && apk add git build-base
WORKDIR /tmp
RUN git clone https://github.com/google/jsonnet.git
RUN cd jsonnet && make jsonnet
RUN cp jsonnet/jsonnet /usr/local/bin
COPY execution.sh ./
RUN chmod -R a+rwx ./
USER 1001
CMD ["sh", "execution.sh"]
