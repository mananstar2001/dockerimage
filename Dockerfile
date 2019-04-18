FROM alpine

RUN apk update && apk add git build-base
WORKDIR /tmp
RUN git clone https://github.com/google/jsonnet.git
RUN cd jsonnet && make jsonnet
RUN cp jsonnet/jsonnet /usr/local/bin
COPY execution.sh ./
COPY templates ./templates
COPY grafonnet ./grafonnet-lib/grafonnet
RUN mkdir json
RUN chmod -R a+rwx ./
USER 1001
CMD ["sh", "execution.sh"]
