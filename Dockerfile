FROM openjdk:8-jre-alpine

# image metadata
LABEL image.name="k8s-elasticsearch" \
      image.maintainer="Erik Maciejewski <mr.emacski@gmail.com>"

ENV REDACT_VERSION=0.2.0 \
    ELASTICSEARCH_VERSION=5.5.2

RUN apk --no-cache add \
        bash \
        curl \
    # install utils
    && curl -L https://github.com/emacski/k8s-app-config/releases/download/v0.1.0/k8s-app-config -o /usr/bin/k8s-app-config \
    && curl -L https://github.com/emacski/redact/releases/download/v$REDACT_VERSION/redact -o /usr/bin/redact \
    && chmod +x /usr/bin/k8s-app-config /usr/bin/redact \
    # install elasticsearch
    && curl -OL https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELASTICSEARCH_VERSION.tar.gz \
    && tar -xf elasticsearch-$ELASTICSEARCH_VERSION.tar.gz \
    && mv elasticsearch-$ELASTICSEARCH_VERSION elasticsearch \
    && mkdir /data \
    && addgroup -S elasticsearch && adduser -S -G elasticsearch elasticsearch \
    && chown -R elasticsearch:elasticsearch /elasticsearch \
    && chown -R elasticsearch:elasticsearch /data \
    # clean up
    && rm elasticsearch-$ELASTICSEARCH_VERSION.tar.gz \
    && apk del curl

COPY . /

VOLUME ["/data"]

EXPOSE 9200 9300

# build metadata
ARG GIT_URL=none
ARG GIT_COMMIT=none
LABEL build.git.url=$GIT_URL \
      build.git.commit=$GIT_COMMIT

ENTRYPOINT ["redact", "entrypoint", \
            "--pre-render", "/pre-render.sh", \
            "--default-tpl-path", "/elasticsearch.yml.redacted", \
            "--default-cfg-path", "/elasticsearch/config/elasticsearch.yml", \
            "--", \
            "elasticsearch", "/elasticsearch/bin/elasticsearch"]
