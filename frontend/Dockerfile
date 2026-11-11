# Etapa 1: Build da aplicação Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.29.1 AS build
WORKDIR /app

# Cache de dependências do Flutter/Dart
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copia código-fonte e compila para Web com API_URL configurável
COPY . .
ARG API_URL=http://localhost:8080
RUN flutter build web --release --dart-define=API_URL=${API_URL}

# Etapa 2: Servidor estático Nginx otimizado
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]

