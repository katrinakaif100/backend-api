FROM cirrusci/flutter:3.7.0

WORKDIR /app
COPY . .
RUN flutter pub get

CMD ["dart", "run", "lib/main.dart"]
