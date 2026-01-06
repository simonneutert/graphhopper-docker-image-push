FROM maven:3.9-eclipse-temurin-25 as build

WORKDIR /graphhopper

COPY graphhopper .

RUN mvn clean install -DskipTests

FROM eclipse-temurin:25-jre

ENV JAVA_OPTS "-Xmx1g -Xms1g"

RUN mkdir -p /data

WORKDIR /graphhopper

COPY --from=build /graphhopper/web/target/graphhopper*.jar ./

# You can find the latest config-example.yml here:
#
# https://github.com/graphhopper/graphhopper/blob/master/config-example.yml
COPY graphhopper.sh config-example.yml ./

# Enable connections from outside of the container
RUN sed -i '/^ *bind_host/s/^ */&# /p' config-example.yml

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*

VOLUME [ "/data" ]

EXPOSE 8989 8990

HEALTHCHECK --interval=5s --timeout=3s CMD curl --fail http://localhost:8989/health || exit 1

ENTRYPOINT [ "./graphhopper.sh", "-c", "config-example.yml" ]
