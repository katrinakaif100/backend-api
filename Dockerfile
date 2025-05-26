# Gunakan image resmi dari Google untuk Dart
FROM dart:3.6.1

# Install dependensi dasar
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    && apt-get clean

# Download dan install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:$PATH"

# Cek apakah Flutter berhasil diinstal
RUN flutter doctor

# Set working directory
WORKDIR /app

# Copy semua file proyek
COPY . .

# Install dependensi proyek
RUN flutter pub get

# Jalankan aplikasi (opsional)
ENTRYPOINT ["dart", "run", "lib/main.dart"]




