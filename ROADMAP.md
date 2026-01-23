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
| **11. Analytics Dashboard** | Web, Security and Performance tabs with shared time range | `4f7fd75`, `452f58a` | ADR-023 (Analytics Preload) |
| **12. Pages Management** | Account-level project list, deployments, logs and rollback | `be82bef`, `f67d99a` | ADR-027 (Auto-polling) |
| **13. Workers Management** | List, details, triggers, interactive settings and domains | `9ae239a`, [curr] | ADR-028 (Symbols), ADR-029 (Route Persistence) |

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
- [x] Pages management (Feature 12)
- [ ] Workers management (Feature 13)

### UX Improvements
- [ ] Onboarding flow for new users
- [ ] Quick actions from system tray
- [ ] Notifications for zone status changes

---

## Current Sprint

### Feature 13: Cloudflare Workers Management
Description: Gerenciamento de Workers/Scripts com listagem, detalhes, routes e triggers. (Visit file ROADMAP.feat13.md for full research details)
- [x] 13.01 Criar modelos Freezed: Worker, WorkerRoute, WorkerSchedule, WorkerBinding
- [x] 13.02 Adicionar endpoints ao CloudflareApi (Retrofit) para Workers
- [x] 13.03 Criar WorkersProvider com cache e state management (Riverpod)
- [x] 13.04 Implementar tela de listagem de workers (cards com routes/triggers)
- [x] 13.05 Implementar tela de detalhes do worker (tabs: Triggers, Bindings)
- [x] 13.06 Implementar visualização de routes (patterns, zone associada)
- [x] 13.07 Implementar visualização de cron triggers
- [x] 13.08 Implementar visualização de bindings (KV, R2, D1, DO - read-only)
- [x] 13.09 Adicionar navegação no Drawer/BottomNav (ícone: layers)
- [x] 13.10 Localização (i18n) completa EN/PT
- [x] 13.11 Testes unitários (models, providers) e widget tests (verificado via make check)
- [x] 13.12 Implementar CRUD de Rotas e Domínios Customizados
- [x] 13.13 Implementar Edição de Variáveis de Ambiente e Segredos (Secrets)
