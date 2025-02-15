FROM dart:stable AS build

WORKDIR /app
COPY . .
RUN dart pub get

CMD ["dart", "run", "lib/main.dart"]
