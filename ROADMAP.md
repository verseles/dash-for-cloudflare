---
feature: "Dash for CF"
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
| **5. UI/Widgets** | Material 3 theme, GoRouter, DNS pages, Analytics charts, Settings. AMOLED dark mode, expandable log details. | `c2a1a07`, `06a826a`, `5dc39c2`, `ebf65ef` | ADR-006 (Syncfusion), ADR-012 (SfMaps), ADR-017 (Zone Selection), ADR-018 (Delete Delay), ADR-034 (AMOLED) |
| **6. i18n** | English + Portuguese, intl formatting | `06a826a` | - |
| **7. Desktop** | window_manager, system tray, keyboard shortcuts | - | - |
| **8. PWA** | manifest, service worker, install prompt, _headers | `7e86061` | - |
| **9. Tests** | 243 tests across 46 test files. Test pyramid: unit, widget, integration. Retry logic with expanded coverage. | `f997c92`, `91ac152` | ADR-030 (Test Pyramid) |
| **10. Build & Deploy** | Icons, splash, APK, Linux, Web, CI/CD GitHub Actions | `6cf983e`, `678b974` | ADR-025 (Data Centers Sync), ADR-026 (GitHub Actions Deploy) |
| **11. DNS & Analytics** | DNS pagination for large zones. Analytics dashboard: Web, Security and Performance tabs with shared time range. Debug logs with search and filtering. | `4f7fd75`, `452f58a`, `82e90a1`, `b13fea6` | ADR-023 (Analytics Preload), ADR-021 (Logging) |
| **12. Pages Management** | Account-level project list, deployments, logs and rollback. Email Security (SPF/DKIM) and Git Build settings. | `be82bef`, `f67d99a`, `f429321` | ADR-027 (Auto-polling), ADR-031 (Auto-save), ADR-032 (Smart Placement) |
| **13. Workers Management** | List, details, triggers, interactive settings and domains. Real-time Tail Logs via WebSocket with filtering. | `9ae239a`, `e53284e`, `f429321` | ADR-022 (Cache), ADR-024 (Preload), ADR-028 (Symbols), ADR-029 (Route Persistence), ADR-035 (Tail Logs) |
| **14. CI/CD Quality Gates** | Automated quality enforcement: analyzer budget (max 50 issues), coverage threshold (min 25%), generated code verification. Automated release workflow with GitHub Releases. Token sanitization in logs. | `6d7ca49`, `8569e60` | ADR-036 (CI/CD), ADR-037 (Token Sanitization) |

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
- [x] Pagination for zones with many DNS records (Feature 11)
- [ ] Bulk DNS record operations

### New Cloudflare Features
- [ ] Firewall rules management
- [ ] Page rules management  
- [ ] SSL/TLS settings
- [ ] Caching settings
- [x] Pages management (Feature 12)
- [x] Workers management (Feature 13)

### UX Improvements
- [x] Smooth animations and modern UI effects (shimmer skeletons, staggered lists, state transitions, page transitions, micro-interactions) - Commit hash: 85155d1
- [ ] Onboarding flow for new users
- [ ] Quick actions from system tray
- [ ] Notifications for zone status changes
