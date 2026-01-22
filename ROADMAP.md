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
- [~] Pages management (Feature 12)
- [ ] Workers management (Feature 13)

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

### Feature 12: Cloudflare Pages Management
Description: Gerenciamento de projetos Pages com listagem, detalhes, deployments e rollback. (Visit file ROADMAP.feat12.md for full research details)
- [ ] 12.01 Criar modelos Freezed: PagesProject, PagesDeployment, BuildConfig, DeploymentStage
- [ ] 12.02 Adicionar endpoints ao CloudflareApi (Retrofit) para Pages
- [ ] 12.03 Criar PagesProvider com cache e state management (Riverpod)
- [ ] 12.04 Implementar tela de listagem de projetos (cards com status, last deploy)
- [ ] 12.05 Implementar tela de detalhes do projeto (tabs: Deployments, Domains)
- [ ] 12.06 Implementar visualização de deployment (logs, preview URL, commit info)
- [ ] 12.07 Implementar ação de rollback com confirmação
- [ ] 12.08 Adicionar navegação no Drawer/BottomNav (ícone: web_asset)
- [ ] 12.09 Localização (i18n) completa EN/PT
- [ ] 12.10 Testes unitários (models, providers) e widget tests

### Feature 13: Cloudflare Workers Management
Description: Gerenciamento de Workers/Scripts com listagem, detalhes, routes e triggers. (Visit file ROADMAP.feat13.md for full research details)
- [ ] 13.01 Criar modelos Freezed: Worker, WorkerRoute, WorkerSchedule, WorkerBinding
- [ ] 13.02 Adicionar endpoints ao CloudflareApi (Retrofit) para Workers
- [ ] 13.03 Criar WorkersProvider com cache e state management (Riverpod)
- [ ] 13.04 Implementar tela de listagem de workers (cards com routes/triggers)
- [ ] 13.05 Implementar tela de detalhes do worker (tabs: Triggers, Bindings)
- [ ] 13.06 Implementar visualização de routes (patterns, zone associada)
- [ ] 13.07 Implementar visualização de cron triggers
- [ ] 13.08 Implementar visualização de bindings (KV, R2, D1, DO - read-only)
- [ ] 13.09 Adicionar navegação no Drawer/BottomNav (ícone: code)
- [ ] 13.10 Localização (i18n) completa EN/PT
- [ ] 13.11 Testes unitários (models, providers) e widget tests
