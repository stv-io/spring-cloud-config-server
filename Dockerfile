FROM docker.io/library/gradle:7.6.0-jdk19-focal as build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN gradle build --no-daemon 

FROM docker.io/library/openjdk:19-jdk-slim
RUN mkdir /app
COPY --from=build /home/gradle/src/build/libs/*.jar /app/spring-boot-application.jar
ENV JAVA_TOOL_OPTIONS="-Dserver.port=8888 -Dspring.config.name=application -Dspring.config.additional-location=optional:file:/config/ -Dspring.cloud.config.server.native.searchLocations=classpath:/,classpath:/config,file:./,file:./config,file:/config"
EXPOSE 8888
ENTRYPOINT ["sh", "-c", "exec java $JAVA_TOOL_OPTIONS -jar /app/spring-boot-application.jar"]