#!/bin/bash
set -e
cd "$(dirname "$0")/.."
export PATH="$HOME/.flutter-sdk/bin:$PATH"

echo "→ Generating app icon…"
python3 tool/generate_app_icon.py 2>/dev/null || true

echo "→ Building web (personal mode)…"
flutter build web --release \
  --wasm \
  --dart-define=PERSONAL_MODE=true \
  --base-href="/"

echo "→ Verifying queen photo in build…"
test -f build/web/images/queen_avatar.png || cp -r web/images build/web/images

echo "→ Starting server at http://localhost:8080"
echo "  Hard refresh in Chrome: Cmd+Shift+R"
cd build/web && python3 -m http.server 8080
