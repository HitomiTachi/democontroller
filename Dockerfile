# Stage 1: Build JAR
FROM maven:3.9.11-eclipse-temurin-17 AS builder
WORKDIR /app
COPY democontroller/ .
RUN mvn clean package -DskipTests

# Stage 2: Run app
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]