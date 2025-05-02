FROM maven:3.8.6-openjdk-21-slim AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

FROM openjdk:21-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Create directory for H2 database
RUN mkdir -p /root/.docs/documentation

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
