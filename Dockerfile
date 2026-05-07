FROM eclipse-temurin:17-jre

WORKDIR /app

COPY saxon-he-12.9.jar /app/
COPY lib /app/lib
COPY src /app/src



