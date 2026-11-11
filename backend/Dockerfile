# Etapa 1: Build da aplicação
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /workspace

# Cache de dependências Maven
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x ./mvnw && ./mvnw dependency:go-offline -B

# Compilação e empacotamento
COPY src ./src
RUN ./mvnw clean package -DskipTests -B

# Etapa 2: Imagem final de runtime
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Usuário não-root para execução segura
RUN useradd -r -u 1001 -g root springboot && \
    mkdir -p /app/uploads && \
    chown -R springboot:root /app

USER springboot

COPY --from=build --chown=springboot:root /workspace/target/*.war app.war

ENV PORT=8080 \
    SPRING_PROFILES_ACTIVE=prod \
    STORAGE_LOCATION=/app/uploads

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health | grep -q 'UP' || exit 1

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.war"]

