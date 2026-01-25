.PHONY: all check precommit deps gen analyze test linux android android-x64 web cf-pages clean install uninstall help sync-datacenters icons

# ══════════════════════════════════════════════════════════════════════════════
# Dash for Cloudflare - Makefile
# ══════════════════════════════════════════════════════════════════════════════
#
# Workflow:
#   make check      - Quick validation during development (~20s)
#   make precommit  - Full verification before commit (~30s)
#
# All commands suppress successful output to save tokens.
# Logs only shown on errors.
#
# ══════════════════════════════════════════════════════════════════════════════

# Paths
LINUX_BUNDLE = build/linux/x64/release/bundle
APK_DIR = build/app/outputs/flutter-apk
APK_PATH = $(APK_DIR)/dash-for-cf.apk
WEB_PATH = build/web
INSTALL_DIR = $(HOME)/.local

# Temp log file
LOG = /tmp/dash-cf-build.log

# ══════════════════════════════════════════════════════════════════════════════
# Output control: TTY detection with explicit override
#
# - Interactive terminal (user): show full output
# - Non-interactive (agent/CI): suppress successful output, show only errors
# - VERBOSE=1: force full output regardless of TTY
# ══════════════════════════════════════════════════════════════════════════════
ifeq ($(VERBOSE),1)
    # Explicit verbose mode
    RUN =
    RUN_LENIENT =
else ifeq ($(shell [ -t 1 ] && echo 1),1)
    # Interactive terminal - show output
    RUN =
    RUN_LENIENT =
else
    # Non-interactive (agent/CI) - suppress successful output
    RUN = > $(LOG) 2>&1 || (cat $(LOG) && exit 1)
    RUN_LENIENT = > $(LOG) 2>&1 || (cat $(LOG) && true)
endif

# Default target
all: help

# ══════════════════════════════════════════════════════════════════════════════
# CHECK - Quick validation (deps + gen + analyze + test)
# ══════════════════════════════════════════════════════════════════════════════
check:
	@echo "══════════════════════════════════════════════════════════════"
	@echo "  CHECK - Quick Validation"
	@echo "══════════════════════════════════════════════════════════════"
	@echo ""
	@echo "[1/4] Installing dependencies..."
	@flutter pub get $(RUN)
	@echo "✓ Dependencies installed"
	@echo ""
	@echo "[2/4] Generating code (build_runner)..."
	@dart run build_runner build --delete-conflicting-outputs $(RUN)
	@echo "✓ Code generated"
	@echo ""
	@echo "[3/4] Static Analysis..."
	@flutter analyze --no-fatal-infos $(RUN)
	@echo "✓ Analysis passed"
	@echo ""
	@echo "[4/4] Running Tests..."
	@flutter test $(RUN)
	@echo "✓ All tests passed"
	@echo ""
	@echo "══════════════════════════════════════════════════════════════"
	@echo "  ✅ CHECK PASSED"
	@echo "══════════════════════════════════════════════════════════════"

# ══════════════════════════════════════════════════════════════════════════════
# PRECOMMIT - Full verification (check + builds)
# ══════════════════════════════════════════════════════════════════════════════
precommit: check
	@echo ""
	@echo "══════════════════════════════════════════════════════════════"
	@echo "  PRECOMMIT - Build Verification"
	@echo "══════════════════════════════════════════════════════════════"
	@echo ""
	@echo "[5/6] Linux Build..."
	@flutter build linux --release $(RUN_LENIENT)
	@if [ -d "$(LINUX_BUNDLE)" ]; then echo "✓ Linux build successful"; else echo "⚠ Linux build skipped (not on Linux or missing deps)"; fi
	@echo ""
	@echo "[6/6] Android Build & Upload..."
	@$(MAKE) android VERBOSE=$(VERBOSE)
	@echo ""
	@echo "══════════════════════════════════════════════════════════════"
	@echo "  ✅ PRECOMMIT PASSED - Safe to commit!"
	@echo "══════════════════════════════════════════════════════════════"

# ══════════════════════════════════════════════════════════════════════════════
# BUILD TARGETS
# ══════════════════════════════════════════════════════════════════════════════

# Install dependencies
deps: sync-datacenters
	@echo "Installing dependencies..."
	@flutter pub get $(RUN)
	@echo "✓ Dependencies installed"

# Regenerate app icons and splash screens
icons:
	@echo "Regenerating icons and splash..."
	@dart run flutter_launcher_icons $(RUN)
	@dart run flutter_native_splash:create $(RUN)
	@echo "Fixing Android adaptive icon XML (removing inset)..."
	@echo '<?xml version="1.0" encoding="utf-8"?>' > android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
	@echo '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">' >> android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
	@echo '  <background android:drawable="@color/ic_launcher_background"/>' >> android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
	@echo '  <foreground android:drawable="@drawable/ic_launcher_foreground"/>' >> android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
	@echo '</adaptive-icon>' >> android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
	@echo "✓ Icons and splash regenerated"

# Generate code (Freezed, Retrofit, JSON Serializable)
gen:
	@echo "Generating code (build_runner)..."
	@dart run build_runner build --delete-conflicting-outputs $(RUN)
	@echo "✓ Code generated"

# Static analysis
analyze:
	@echo "Running static analysis..."
	@flutter analyze --no-fatal-infos $(RUN)
	@echo "✓ Analysis passed"

# Run tests
test:
	@echo "Running tests..."
	@flutter test $(RUN)
	@echo "✓ All tests passed"

# Linux release build
linux:
	@echo "Building Linux release..."
	@flutter build linux --release $(RUN)
	@echo "✓ Linux build complete"
	@echo "  Bundle: $(LINUX_BUNDLE)/"
	@ls -lh $(LINUX_BUNDLE)/dash_for_cloudflare 2>/dev/null || true

# Android release build + tdl upload
android:
	@echo "Building Android APK (arm64)..."
	@flutter build apk --release --target-platform android-arm64 $(RUN)
	@mv -f $(APK_DIR)/app-release.apk $(APK_PATH)
	@echo "✓ Android build complete"
	@echo "  APK: $(APK_PATH)"
	@ls -lh $(APK_PATH)
	@echo ""
	@if command -v tdl >/dev/null 2>&1; then \
		echo "Uploading APK via tdl..."; \
		if tdl up -c 3305021517 -t 6 --path=$(APK_PATH); then \
			echo "✓ APK uploaded"; \
		else \
			echo "✗ APK upload failed"; \
			exit 1; \
		fi \
	else \
		echo "ℹ tdl not found - skipping upload"; \
	fi

# Android x64 build (for emulator)
android-x64:
	@echo "Building Android APK (x64 for emulator)..."
	@flutter build apk --release --target-platform android-x64 $(RUN)
	@mv -f $(APK_DIR)/app-release.apk $(APK_PATH)
	@echo "✓ Android x64 build complete"
	@echo "  APK: $(APK_PATH)"
	@ls -lh $(APK_PATH)


# Web release build
web:
	@echo "Building Web release..."
	@flutter build web --release $(RUN)
	@echo "✓ Web build complete"
	@echo "  Output: $(WEB_PATH)/"
	@du -sh $(WEB_PATH)

# Cloudflare Pages build command (for CI)
# Copy this output to Cloudflare Pages "Build command" field
cf-pages:
	@echo 'git clone --depth 1 -b stable https://github.com/flutter/flutter.git && export PATH="$$PATH:$$PWD/flutter/bin" && flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter build web --release'

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@flutter clean $(RUN)
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
	@cp -r $(LINUX_BUNDLE)/* $(INSTALL_DIR)/share/dash-for-cloudflare/
	@ln -sf $(INSTALL_DIR)/share/dash-for-cloudflare/dash_for_cloudflare $(INSTALL_DIR)/bin/dash-cf
	@echo "[Desktop Entry]" > $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Name=Dash for Cloudflare" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Comment=Unofficial Cloudflare management app" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Exec=$(INSTALL_DIR)/share/dash-for-cloudflare/dash_for_cloudflare" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Icon=$(INSTALL_DIR)/share/icons/hicolor/128x128/apps/ad.dash.cf.png" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Terminal=false" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Type=Application" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@echo "Categories=Network;Utility;" >> $(INSTALL_DIR)/share/applications/ad.dash.cf.desktop
	@cp assets/icons/app_icon.png $(INSTALL_DIR)/share/icons/hicolor/128x128/apps/ad.dash.cf.png 2>/dev/null || \
		cp android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png $(INSTALL_DIR)/share/icons/hicolor/128x128/apps/ad.dash.cf.png 2>/dev/null || true
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
# DATA SYNC
# ══════════════════════════════════════════════════════════════════════════════

# Sync Cloudflare data centers list from GitHub
sync-datacenters:
	@echo "Syncing Cloudflare data centers..."
	@curl -sfL "https://raw.githubusercontent.com/insign/Cloudflare-Data-Center-IATA-Code-list/main/cloudflare-iata-full.json" \
		-o assets/data/cloudflare-iata-full.json $(RUN)
	@echo "✓ Data centers synced"

# ══════════════════════════════════════════════════════════════════════════════
# HELP
# ══════════════════════════════════════════════════════════════════════════════

help:
	@echo "Dash for Cloudflare - Build Commands"
	@echo ""
	@echo "  Validation:"
	@echo "    make check      Quick validation (deps+gen+analyze+test) ~20s"
	@echo "    make precommit  Full verification (check+builds) ~30s"
	@echo ""
	@echo "  Build:"
	@echo "    make android     Build APK (arm64) + upload via tdl"
	@echo "    make android-x64 Build APK (x64 for emulator)"
	@echo "    make linux       Build Linux release"
	@echo "    make web         Build Web release"
	@echo "    make cf-pages    Show build command for Cloudflare Pages CI"
	@echo ""
	@echo "  Development:"
	@echo "    make deps             Install dependencies (+ sync data centers)"
	@echo "    make sync-datacenters Update Cloudflare data centers list"
	@echo "    make gen              Generate code (Freezed, Retrofit)"
	@echo "    make icons            Regenerate app icons and splash screens"
	@echo "    make test        Run tests only"
	@echo "    make analyze     Static analysis only"
	@echo "    make clean       Clean build artifacts"
	@echo ""
	@echo "  Linux Install:"
	@echo "    make install     Install to ~/.local"
	@echo "    make uninstall   Remove from ~/.local"
	@echo ""
	@echo "Workflow: make check (during dev) -> make precommit (before commit)"
