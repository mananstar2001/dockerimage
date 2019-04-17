FROM alpine

RUN apk update && apk add git build-base
WORKDIR /tmp
RUN git clone https://github.com/google/jsonnet.git
RUN cd jsonnet && make jsonnet
RUN cp jsonnet/jsonnet /usr/local/bin
COPY execution.sh ./
RUN chmod -R a+rwx ./
RUN chmod -R a+rwx /etc/hosts
USER 1001
CMD ["sh", "execution.sh"]
