FROM openjdk:8-jre-alpine

# image metadata
LABEL image.name="k8s-elasticsearch" \
      image.maintainer="Erik Maciejewski <mr.emacski@gmail.com>"

ENV ELASTICSEARCH_VERSION=5.4.1

RUN apk --no-cache add \
    'su-exec>=0.2' \
    bash \
    curl \
  # install utils
  && curl -L https://github.com/emacski/k8s-app-config/releases/download/v0.1.0/k8s-app-config -o /usr/local/bin/k8s-app-config \
  && curl -L https://github.com/emacski/env-config-writer/releases/download/v0.1.0/env-config-writer -o /usr/local/bin/env-config-writer \
  && chmod +x /usr/local/bin/k8s-app-config /usr/local/bin/env-config-writer \
  # install elasticsearch
  && curl -OL https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELASTICSEARCH_VERSION.tar.gz \
  && tar -xf elasticsearch-$ELASTICSEARCH_VERSION.tar.gz \
  && mkdir /data \
  && addgroup -S elasticsearch && adduser -S -G elasticsearch elasticsearch \
  && chown -R elasticsearch:elasticsearch /elasticsearch-$ELASTICSEARCH_VERSION \
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

ENTRYPOINT ["/elasticsearch-config-wrapper"]
