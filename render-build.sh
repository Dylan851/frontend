#!/usr/bin/env bash
set -euo pipefail

# Resolve Flutter binary in a robust way for Render builds.
FLUTTER_BIN=""
if command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN="$(command -v flutter)"
elif [ -x "$HOME/flutter/bin/flutter" ]; then
  FLUTTER_BIN="$HOME/flutter/bin/flutter"
else
  # Reuse cached Flutter SDK directory on Render if it already exists.
  if [ ! -d "$HOME/flutter" ]; then
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
  fi
  FLUTTER_BIN="$HOME/flutter/bin/flutter"
fi

if [ ! -x "$FLUTTER_BIN" ]; then
  echo "Flutter binary not found at: $FLUTTER_BIN"
  exit 1
fi

: "${API_BASE_URL:?API_BASE_URL env var is required (e.g. https://your-backend.onrender.com)}"
: "${SUPABASE_URL:?SUPABASE_URL env var is required}"
: "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY env var is required}"

"$FLUTTER_BIN" --version
"$FLUTTER_BIN" config --enable-web

# pub.dev advisory feed can intermittently return malformed payloads.
# Retry pub get and fallback to offline if dependencies were already cached.
pub_get_ok=0
for i in 1 2 3; do
  echo "Running flutter pub get (attempt $i/3)..."
  if "$FLUTTER_BIN" pub get; then
    pub_get_ok=1
    break
  fi
  echo "flutter pub get failed on attempt $i."
  sleep 2
done

if [ "$pub_get_ok" -ne 1 ]; then
  echo "Retrying with --offline as fallback..."
  "$FLUTTER_BIN" pub get --offline
fi
if [ -n "${GOOGLE_WEB_CLIENT_ID:-}" ]; then
  "$FLUTTER_BIN" build web --release \
    --dart-define=API_BASE_URL="${API_BASE_URL%/}" \
    --dart-define=SUPABASE_URL="${SUPABASE_URL%/}" \
    --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}" \
    --dart-define=GOOGLE_WEB_CLIENT_ID="${GOOGLE_WEB_CLIENT_ID}"
else
  "$FLUTTER_BIN" build web --release \
    --dart-define=API_BASE_URL="${API_BASE_URL%/}" \
    --dart-define=SUPABASE_URL="${SUPABASE_URL%/}" \
    --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"
fi
