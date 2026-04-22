FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /app

# Nota: este contenedor solo prepara dependencias.
# La app Flutter se ejecuta en el host (PC) con: flutter run
CMD ["bash", "-lc", "flutter pub get && tail -f /dev/null"]
