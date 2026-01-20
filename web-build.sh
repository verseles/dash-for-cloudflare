#!/bin/bash
set -e

# =============================================================================
# Dash for Cloudflare - Web Build Script
# =============================================================================
# This script uses Eleventy as a wrapper to enable Cloudflare Pages build cache.
# Cloudflare caches .cache/ directory for Eleventy projects.
# We store Flutter SDK in .cache/flutter/ to benefit from this caching.
# =============================================================================

echo "==> Building Eleventy (to trigger Cloudflare cache)..."
npx @11ty/eleventy --input=src --output=_site --quiet

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
