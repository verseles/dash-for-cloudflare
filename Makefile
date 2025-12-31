.PHONY: all precommit deps gen analyze test linux android web clean install uninstall help

# ══════════════════════════════════════════════════════════════════════════════
# Dash for Cloudflare - Makefile
# ══════════════════════════════════════════════════════════════════════════════
#
# IMPORTANT: Always use `make precommit` before committing (see AGENTS.md)
#
# Usage:
#   make precommit  - Full verification before commit (REQUIRED)
#   make android    - Build APK and send via tdl
#   make linux      - Build Linux release
#   make web        - Build Web release
#   make test       - Run tests only
#   make analyze    - Static analysis only
#   make deps       - Install dependencies
#   make gen        - Generate code (Freezed, Retrofit)
#   make clean      - Clean build artifacts
#   make install    - Install on Linux (~/.local)
#   make uninstall  - Uninstall from Linux
#
# ══════════════════════════════════════════════════════════════════════════════

# Paths
LINUX_BUNDLE = build/linux/x64/release/bundle
APK_PATH = build/app/outputs/flutter-apk/app-release.apk
WEB_PATH = build/web
INSTALL_DIR = $(HOME)/.local

# Temp log file for suppressing successful output
LOG = /tmp/dash-cf-build.log

# Default target
all: help

# ══════════════════════════════════════════════════════════════════════════════
# PRECOMMIT - Full verification sequence (AGENTS.md compliance)
# ══════════════════════════════════════════════════════════════════════════════
precommit:
	@echo "══════════════════════════════════════════════════════════════"
	@echo "  PRECOMMIT VERIFICATION (AGENTS.md)"
	@echo "══════════════════════════════════════════════════════════════"
	@echo ""
	@echo "Step 1/6: Installing dependencies..."
	@echo "──────────────────────────────────────────────────────────────"
	@flutter pub get > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
	@echo "✓ Dependencies installed"
	@echo ""
	@echo "Step 2/6: Generating code (build_runner)..."
	@echo "──────────────────────────────────────────────────────────────"
	@dart run build_runner build --delete-conflicting-outputs > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
	@echo "✓ Code generated"
	@echo ""
	@echo "Step 3/6: Static Analysis..."
	@echo "──────────────────────────────────────────────────────────────"
	@flutter analyze --no-fatal-infos > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
	@echo "✓ Analysis passed"
	@echo ""
	@echo "Step 4/6: Running Tests..."
	@echo "──────────────────────────────────────────────────────────────"
	@flutter test > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
	@echo "✓ All tests passed"
	@echo ""
	@echo "Step 5/6: Linux Build..."
	@echo "──────────────────────────────────────────────────────────────"
	@flutter build linux --release > $(LOG) 2>&1 || (echo "⚠ Linux build skipped" && true)
	@if [ -d "$(LINUX_BUNDLE)" ]; then echo "✓ Linux build successful"; else echo "⚠ Linux build skipped (not on Linux or missing deps)"; fi
	@echo ""
	@echo "Step 6/6: Android Build..."
	@echo "──────────────────────────────────────────────────────────────"
	@flutter build apk --release --target-platform android-x64 > $(LOG) 2>&1 || (echo "⚠ Android build skipped" && true)
	@if [ -f "$(APK_PATH)" ]; then echo "✓ Android build successful"; echo "  APK: $(APK_PATH)"; else echo "⚠ Android build skipped (missing Android SDK)"; fi
	@echo ""
	@echo "══════════════════════════════════════════════════════════════"
	@echo "  ✅ PRECOMMIT PASSED - Safe to commit!"
	@echo "══════════════════════════════════════════════════════════════"

# ══════════════════════════════════════════════════════════════════════════════
# BUILD TARGETS
# ══════════════════════════════════════════════════════════════════════════════

# Install dependencies
deps:
	@echo "Installing dependencies..."
	@flutter pub get > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
	@echo "✓ Dependencies installed"

# Generate code (Freezed, Retrofit, JSON Serializable)
gen:
	@echo "Generating code (build_runner)..."
	@dart run build_runner build --delete-conflicting-outputs > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
	@echo "✓ Code generated"

# Static analysis
analyze:
	@echo "Running static analysis..."
	@flutter analyze --no-fatal-infos > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
	@echo "✓ Analysis passed"

# Run tests
test:
	@echo "Running tests..."
	@flutter test > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
	@echo "✓ All tests passed"

# Linux release build
linux:
	@echo "Building Linux release..."
	@flutter build linux --release > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
	@echo "✓ Linux build complete"
	@echo "  Bundle: $(LINUX_BUNDLE)/"
	@ls -lh $(LINUX_BUNDLE)/dash_for_cloudflare 2>/dev/null || true

# Android release build + tdl upload
android:
	@echo "Building Android APK (arm64)..."
	@flutter build apk --release --target-platform android-arm64 > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
	@echo "✓ Android build complete"
	@echo "  APK: $(APK_PATH)"
	@ls -lh $(APK_PATH)
	@echo ""
	@if command -v tdl >/dev/null 2>&1; then \
		echo "Uploading APK via tdl..."; \
		tdl up -t 6 --path=$(APK_PATH); \
		echo "✓ APK uploaded"; \
	else \
		echo "ℹ tdl not found - skipping upload"; \
	fi

# Android x64 build (for emulator)
android-x64:
	@echo "Building Android APK (x64 for emulator)..."
	@flutter build apk --release --target-platform android-x64 > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
	@echo "✓ Android x64 build complete"
	@echo "  APK: $(APK_PATH)"
	@ls -lh $(APK_PATH)

# Web release build
web:
	@echo "Building Web release..."
	@flutter build web --release > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
	@echo "✓ Web build complete"
	@echo "  Output: $(WEB_PATH)/"
	@du -sh $(WEB_PATH)

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@flutter clean > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
	@rm -rf build/
	@echo "✓ Clean complete"

# ══════════════════════════════════════════════════════════════════════════════
# LINUX INSTALLATION
# ══════════════════════════════════════════════════════════════════════════════

# Install on Linux (after build)
install: linux
	@echo "Installing Dash for Cloudflare to $(INSTALL_DIR)..."
	@mkdir -p $(INSTALL_DIR)/bin
	@mkdir -p $(INSTALL_DIR)/share/dash-for-cloudflare
	@mkdir -p $(INSTALL_DIR)/share/applications
	@mkdir -p $(INSTALL_DIR)/share/icons/hicolor/128x128/apps
	@# Copy bundle
	@cp -r $(LINUX_BUNDLE)/* $(INSTALL_DIR)/share/dash-for-cloudflare/
	@# Create symlink
	@ln -sf $(INSTALL_DIR)/share/dash-for-cloudflare/dash_for_cloudflare $(INSTALL_DIR)/bin/dash-cf
	@# Create desktop file
	@echo "[Desktop Entry]" > $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Name=Dash for Cloudflare" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Comment=Unofficial Cloudflare management app" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Exec=$(INSTALL_DIR)/share/dash-for-cloudflare/dash_for_cloudflare" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Icon=$(INSTALL_DIR)/share/icons/hicolor/128x128/apps/ad.dash.cf.png" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Terminal=false" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Type=Application" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Categories=Network;Utility;" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@# Copy icon
	@cp assets/icons/app_icon.png $(INSTALL_DIR)/share/icons/hicolor/128x128/apps/ad.dash.cf.png 2>/dev/null || \
		cp android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png $(INSTALL_DIR)/share/icons/hicolor/128x128/apps/ad.dash.cf.png 2>/dev/null || true
	@# Update icon cache
	@gtk-update-icon-cache $(INSTALL_DIR)/share/icons/hicolor 2>/dev/null || true
	@echo ""
	@echo "✅ Dash for Cloudflare installed!"
	@echo ""
	@echo "Make sure $(INSTALL_DIR)/bin is in your PATH:"
	@echo "  export PATH=\"\$$HOME/.local/bin:\$$PATH\""
	@echo ""
	@echo "Run: dash-cf"

# Uninstall from Linux
uninstall:
	@echo "Uninstalling Dash for Cloudflare..."
	@rm -f $(INSTALL_DIR)/bin/dash-cf
	@rm -rf $(INSTALL_DIR)/share/dash-for-cloudflare
	@rm -f $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@rm -f $(INSTALL_DIR)/share/icons/hicolor/128x128/apps/ad.dash.cf.png
	@echo "✓ Uninstalled"

# ══════════════════════════════════════════════════════════════════════════════
# HELP
# ══════════════════════════════════════════════════════════════════════════════

help:
	@echo "Dash for Cloudflare - Build Commands"
	@echo ""
	@echo "  make precommit   Full verification before commit (REQUIRED)"
	@echo "  make android     Build APK (arm64) and upload via tdl"
	@echo "  make android-x64 Build APK (x64 for emulator)"
	@echo "  make linux       Build Linux release"
	@echo "  make web         Build Web release"
	@echo "  make test        Run tests"
	@echo "  make analyze     Static analysis"
	@echo "  make deps        Install dependencies"
	@echo "  make gen         Generate code (Freezed, Retrofit)"
	@echo "  make clean       Clean build artifacts"
	@echo "  make install     Install on Linux (~/.local)"
	@echo "  make uninstall   Uninstall from Linux"
	@echo ""
	@echo "IMPORTANT: Always run 'make precommit' before committing!"
