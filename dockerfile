FROM openjdk:17-jdk-slim

WORKDIR /app

COPY SpringApp-0.0.1-SNAPSHOT.jar /app/SpringApp.jar

ENTRYPOINT ["java", "-jar", "/app/SpringApp.jar"]
