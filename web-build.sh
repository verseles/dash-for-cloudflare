#!/bin/bash
set -e

# =============================================================================
# Dash for Cloudflare - Web Build Script
# =============================================================================
# Eleventy is called from package.json before this script runs.
# This enables Cloudflare Pages to detect Eleventy and cache .cache/ directory.
# Flutter SDK is stored in .cache/flutter/ to benefit from this caching.
# =============================================================================

FLUTTER_CACHE=".cache/flutter"

# Download Flutter SDK if not cached
if [ ! -f "$FLUTTER_CACHE/bin/flutter" ]; then
  echo "==> Downloading Flutter SDK (not in cache)..."
  mkdir -p .cache
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_CACHE"
else
  echo "==> Using cached Flutter SDK"
fi

export PATH="$PATH:$PWD/$FLUTTER_CACHE/bin"

echo "==> Flutter version:"
flutter --version

echo "==> Installing dependencies..."
flutter pub get

echo "==> Generating code (Freezed, Retrofit)..."
dart run build_runner build --delete-conflicting-outputs

echo "==> Building web release..."
flutter build web --release

echo "==> Build complete!"
