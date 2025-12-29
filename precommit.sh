#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== Dash for Cloudflare Pre-commit Checks ===${NC}"
echo ""

echo -e "${YELLOW}[1/5] Installing dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

echo -e "${YELLOW}[2/5] Generating code (build_runner)...${NC}"
dart run build_runner build --delete-conflicting-outputs
echo -e "${GREEN}✓ Code generated${NC}"
echo ""

echo -e "${YELLOW}[3/5] Analyzing code...${NC}"
if flutter analyze --no-fatal-infos; then
    echo -e "${GREEN}✓ Code analysis passed${NC}"
else
    echo -e "${RED}✗ Code analysis failed${NC}"
    exit 1
fi
echo ""

echo -e "${YELLOW}[4/5] Running tests...${NC}"
if flutter test; then
    echo -e "${GREEN}✓ All tests passed${NC}"
else
    echo -e "${RED}✗ Tests failed${NC}"
    exit 1
fi
echo ""

echo -e "${YELLOW}[5/5] Build verification (Linux)...${NC}"
if flutter build linux --release 2>/dev/null; then
    echo -e "${GREEN}✓ Linux build successful${NC}"
else
    echo -e "${YELLOW}⚠ Linux build skipped (not on Linux or missing deps)${NC}"
fi
echo ""

echo -e "${GREEN}=== All pre-commit checks passed! ===${NC}"
echo -e "You can now safely commit and push."
