FROM openjdk:17-jdk-slim
ARG JAR_FILE=target/backend-0.0.1.jar
COPY ${JAR_FILE} app_evento.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app_evento.jar"]
LABEL authors="gioco"


