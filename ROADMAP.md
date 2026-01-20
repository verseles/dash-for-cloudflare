---
feature: "Dash for Cloudflare"
spec: |
  Flutter app for Cloudflare management. Stack: Flutter 3.x, Riverpod 2.x, Dio+Retrofit, go_router, Freezed, Syncfusion Charts/Maps. 
  Platforms: Android, iOS, Web, Linux, macOS, Windows. CORS: Web uses cors.verseles.com proxy.
---

## Completed Features

| Feature | Description | Commits | ADRs |
|---------|-------------|---------|------|
| **1. Project Setup** | Flutter project, feature-based structure, dependencies | Initial commits | ADR-001 (Retrofit), ADR-015 (Makefile) |
| **2. Data Models** | Freezed models: Zone, DnsRecord, Analytics, Settings | - | - |
| **3. API Layer** | Dio, Retrofit, GraphQL, interceptors, CORS proxy | - | ADR-003 (CORS), ADR-019 (GraphQL) |
| **4. State Management** | Riverpod notifiers with race condition prevention, caching | `7961256` | ADR-007 (Race Condition), ADR-008 (DataCenters), ADR-009 (Optimistic), ADR-010 (DNSSEC Polling), ADR-022 (Cache), ADR-023 (Analytics Preload), ADR-024 (Tab Preload) |
| **5. UI/Widgets** | Material 3 theme, GoRouter, DNS pages, Analytics charts, Settings | `c2a1a07`, `06a826a` | ADR-006 (Syncfusion), ADR-012 (SfMaps), ADR-017 (Zone Selection), ADR-018 (Delete Delay) |
| **6. i18n** | English + Portuguese, intl formatting | `06a826a` | - |
| **7. Desktop** | window_manager, system tray, keyboard shortcuts | - | - |
| **8. PWA** | manifest, service worker, install prompt, _headers | `7e86061` | - |
| **9. Tests** | 129 tests: models (79), API (8), interceptors (13), widgets (29) | `f997c92` | - |
| **10. Build & Deploy** | Icons, splash, APK, Linux, Web, CI/CD GitHub Actions | `6cf983e`, `678b974` | ADR-025 (Data Centers Sync), ADR-026 (GitHub Actions Deploy) |

## Deferred Items

| Item | Reason |
|------|--------|
| 7.05 Distribution (AppImage, .exe, .dmg) | Low priority |
| 9.06-9.08 Provider/Integration tests | Time constraints |
| 10.04 iOS build | Requires macOS |
| 10.07 Windows/macOS builds | Low priority |
| 10.10 iOS CI/CD | Requires macOS |

---

## Backlog

_New features and improvements to be planned._

### Performance & Polish
- [ ] Offline mode with full cache support
- [ ] Pagination for zones with many DNS records
- [ ] Bulk DNS record operations

### New Cloudflare Features
- [ ] Firewall rules management
- [ ] Page rules management  
- [ ] SSL/TLS settings
- [ ] Caching settings
- [ ] Workers management

### UX Improvements
- [ ] Onboarding flow for new users
- [ ] Quick actions from system tray
- [ ] Notifications for zone status changes

---

## Current Sprint

### Feature 11: Main Analytics Dashboard
Description: Nova seção de Analytics consolidada com abas Web, Security e Performance.
- [x] 11.01 Criar modelos de dados Web, Security e Performance com Freezed
- [x] 11.02 Implementar queries GraphQL para tráfego, segurança e cache
- [x] 11.03 Configurar rotas e navegação no Drawer e BottomNav
- [x] 11.04 Criar SharedAnalyticsTimeRangeProvider para sincronizar filtros
- [x] 11.05 Implementar UI da aba Web (Traffic Analytics)
- [x] 11.06 Implementar UI da aba Performance (Cache Analytics)
- [x] 11.07 Implementar UI da aba Security (Firewall Analytics) com fallback para planos free
- [x] 11.08 Corrigir erros de schema GraphQL (Web/Performance) e access denied (Security)
