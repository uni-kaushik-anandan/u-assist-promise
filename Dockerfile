FROM adoptopenjdk/openjdk8:alpine-slim
LABEL MAINTAINER=uniphore.com
RUN apk update && apk add --upgrade openjdk8 && apk upgrade
ARG JAR_FILE=./u-assist-promise/target/u-assist-promise.jar
ARG DATADOG_AGENT_JAR_FILE=./u-assist-promise/internal-lib/dd-java-agent-1.10.0.jar
COPY ${DATADOG_AGENT_JAR_FILE} /opt/app/lib/dd-java-agent.jar
COPY ${JAR_FILE} /opt/app/lib/app.jar
COPY ./logback.xml /opt/app/conf/logback.xml
RUN mkdir -p /var/log/uniphore
RUN chmod -R 777 /var/log/uniphore
ENV SPRING_APPLICATION_JSON='{"spring":{"application":{"name":"u-assist-promise"},"profiles":{"active":"redis,kafka,mongo"}}, \
    "logging": {"config": "file:/opt/app/conf/logback.xml"}, \
	"server": {"port": 3381}}'
RUN addgroup -g 8000 -S uniphore 
RUN adduser -h /home/uniphore -u 8001 -G uniphore -s /bin/sh -k /dev/null -S uniphore
USER 8001
ENTRYPOINT exec java -javaagent:/opt/app/lib/dd-java-agent.jar -XshowSettings:vm -XX:FlightRecorderOptions=stackdepth=256 $JAVA_OPTS -jar /opt/app/lib/app.jar