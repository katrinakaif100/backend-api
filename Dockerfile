FROM cirrusci/flutter:stable

WORKDIR /app

COPY . .

RUN dart pub get

CMD ["dart", "run", "lib/main.dart"]




