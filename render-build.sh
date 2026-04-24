#!/usr/bin/env bash
set -euo pipefail

# Ensure Flutter is available in Render build environment.
if ! command -v flutter >/dev/null 2>&1; then
  # Reuse cached Flutter SDK directory on Render if it already exists.
  if [ ! -d "$HOME/flutter" ]; then
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
  fi
  export PATH="$HOME/flutter/bin:$PATH"
fi

: "${API_BASE_URL:?API_BASE_URL env var is required (e.g. https://your-backend.onrender.com)}"

flutter config --enable-web
flutter pub get
flutter build web --release --dart-define=API_BASE_URL="${API_BASE_URL%/}"
