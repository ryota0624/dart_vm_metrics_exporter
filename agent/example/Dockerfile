FROM dart:2.17.5-sdk AS build

# Resolve app dependencies.
WORKDIR /app
COPY . .
RUN dart pub get
EXPOSE 8080
CMD ["dart", "run", "--disable-service-auth-codes", "--observe", "agent/example/server.dart"]
