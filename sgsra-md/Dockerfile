# Etapa 1: Compilacion con Java 21
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app
COPY . .
RUN chmod +x mvnw && ./mvnw clean package -DskipTests

# Etapa 2: Ejecucion ligera
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
# [H-GEN-03] Las imagenes subidas se guardan en PostgreSQL; aqui solo se copian las imagenes semilla del repositorio
COPY --from=build /app/uploads /app/uploads
EXPOSE 8080
ENTRYPOINT ["java", "-Xmx384m", "-jar", "app.jar"]
