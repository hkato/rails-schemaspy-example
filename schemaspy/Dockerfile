FROM openjdk:8u212-alpine3.9

ENV POSTGRESQL_VERSION=42.4.0
ENV SCHEMASPY_VERSION=6.1.0

RUN adduser java -h / -D && \
    set -x && \
    apk add --no-cache \
        curl \
        unzip \
        graphviz \
        fontconfig \
        ttf-dejavu && \
    fc-cache -fv && \
    mkdir -p /usr/local/lib/schemaspy && \
    curl -L https://github.com/schemaspy/schemaspy/releases/download/v${SCHEMASPY_VERSION}/schemaspy-${SCHEMASPY_VERSION}.jar \
        -o /usr/local/lib/schemaspy/schemaspy.jar && \
    mkdir /drivers_inc && \
    cd /drivers_inc && \
    curl -JLO http://search.maven.org/remotecontent?filepath=org/postgresql/postgresql/$POSTGRESQL_VERSION/postgresql-$POSTGRESQL_VERSION.jar && \
    mkdir /output && \
    chown -R java /drivers_inc && \
    chown -R java /output && \
    apk del curl

ADD schemaspy.sh /usr/local/bin/schemaspy
RUN chmod +x /usr/local/bin/schemaspy

USER java
WORKDIR /

ENV SCHEMASPY_DRIVERS=/drivers
ENV SCHEMASPY_OUTPUT=/output

ENTRYPOINT ["/usr/local/bin/schemaspy"]
