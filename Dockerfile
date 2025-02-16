FROM dart:3.7.0

WORKDIR /app
COPY . .
RUN dart pub get

CMD ["dart", "run", "lib/main.dart"]
