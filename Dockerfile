# Multi-stage Dockerfile
FROM openjdk:21-jdk-slim AS build

WORKDIR /app

# Copy maven wrapper and pom.xml first (for better layer caching)
COPY mvnw* ./
COPY pom.xml .
COPY .mvn .mvn

# Make mvnw executable
RUN chmod +x ./mvnw

# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY src src

# Build the application
RUN ./mvnw clean package -DskipTests -B

# Runtime stage
FROM openjdk:21-jdk-slim

WORKDIR /app

# Copy the built JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Create non-root user for security
RUN addgroup --system spring && adduser --system spring --ingroup spring
USER spring:spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]