---
feature: "Dash for Cloudflare Migration (Vue → Flutter)"
spec: |
  Migração completa do projeto Dash for Cloudflare de Vue/Quasar para Flutter. Stack: Flutter 3.x, Riverpod 2.x, Dio+Retrofit, go_router, Freezed, Syncfusion Charts/Maps. Plataformas: Android, iOS, Web, Linux, macOS, Windows. Branch original: old_vue. CORS: Web usa proxy cors.verseles.com, mobile/desktop direto na API.
---

## Task List

### Feature 1: Setup do Projeto
Description: Criar projeto Flutter, estrutura de pastas, dependências e configurações iniciais
- [x] 1.01 Criar projeto Flutter com plataformas: android, ios, web, linux, macos, windows (note: Projeto criado com todas as plataformas)
- [x] 1.02 Configurar package name (ad.dash.cf) e nome do app (note: Package ad.dash.cf configurado)
- [x] 1.03 Criar estrutura feature-based: lib/features/, lib/core/, lib/shared/ (note: Estrutura feature-based criada)
- [x] 1.04 Criar pastas auth, dns, analytics, theme, platform, widgets, l10n (note: Todas as pastas criadas)
- [x] 1.05 Adicionar dependências principais: riverpod, dio, retrofit, go_router, freezed, syncfusion (note: Dependências principais adicionadas)
- [x] 1.06 Adicionar dev_dependencies: build_runner, freezed, json_serializable, mocktail (note: Dev dependencies adicionadas)
- [x] 1.07 Configurar analysis_options.yaml e l10n.yaml (note: analysis_options.yaml e l10n.yaml configurados)

### Feature 2: Modelos de Dados
Description: Criar models com Freezed: Zone, DnsRecord, DnsSetting, DnssecDetails, Analytics, AppSettings
- [x] 2.01 Criar models Zone, ZoneRegistrar com Freezed (note: Models Zone e ZoneRegistrar criados)
- [x] 2.02 Criar models DnsRecord, DnsRecordCreate (note: Models DnsRecord e DnsRecordCreate criados)
- [x] 2.03 Criar models DnsSetting, DnsZoneSettings, DnssecDetails (note: Models DnsSetting, DnsZoneSettings, DnssecDetails criados)
- [x] 2.04 Criar models DnsAnalyticsData, AnalyticsGroup, DataCenterInfo (note: Models Analytics criados)
- [x] 2.05 Criar models CloudflareResponse<T>, CloudflareError, DeleteResponse (note: Models CloudflareResponse criados)
- [x] 2.06 Criar model AppSettings (cloudflareApiToken, themeMode, locale) (note: Model AppSettings criado)
- [x] 2.07 Executar build_runner para gerar .freezed.dart e .g.dart (note: build_runner executado, arquivos gerados)

### Feature 3: Camada de API
Description: Configurar Dio, interceptors, REST API (Retrofit) e GraphQL client
- [x] 3.01 Criar ApiConfig com URLs base (com/sem proxy CORS) (note: ApiConfig com URLs CORS implementado)
- [x] 3.02 Criar PlatformDetector para detectar web vs nativo (note: PlatformDetector implementado)
- [x] 3.03 Criar interceptors: Auth, Retry, RateLimit, Log (note: Interceptors Auth, Retry, RateLimit, Log criados)
- [x] 3.04 Criar interface CloudflareApi com anotações Retrofit (note: Interface CloudflareApi com Retrofit criada)
- [x] 3.05 Implementar endpoints REST: zones, dns_records, dnssec, settings (note: Endpoints REST implementados)
- [x] 3.06 Criar CloudflareGraphQL para analytics (note: CloudflareGraphQL para analytics implementado)
- [x] 3.07 Criar providers: dioProvider, cloudflareApiProvider, cloudflareGraphQLProvider (note: Providers de API criados)

### Feature 4: State Management (Riverpod)
Description: Implementar notifiers: Settings, Zone, DnsRecords, DnsSettings, Analytics, Loading, DataCenters
- [x] 4.01 Criar SettingsNotifier com SecureStorage e SharedPreferences (note: SettingsNotifier implementado)
- [x] 4.02 Criar ZonesNotifier e SelectedZoneNotifier com persistência (note: ZonesNotifier e SelectedZoneNotifier implementados)
- [x] 4.03 Criar DnsRecordsNotifier com race condition prevention (note: DnsRecordsNotifier com race condition prevention)
- [x] 4.04 Criar DnsSettingsNotifier com DNSSEC toggle e polling (note: DnsSettingsNotifier com DNSSEC polling)
- [x] 4.05 Criar AnalyticsNotifier com time range e query names (note: AnalyticsNotifier implementado)
- [x] 4.06 Criar LoadingNotifier para múltiplas operações (note: LoadingNotifier implementado)
- [x] 4.07 Criar DataCentersNotifier com fallback de assets e fetch CDN (note: DataCentersNotifier com fallback assets + CDN fetch)

### Feature 5: UI/Widgets
Description: Implementar tema, routing, layouts, páginas e componentes
- [x] 5.01 Criar AppTheme com light/dark themes e Material 3 (note: AppTheme com light/dark e Material 3)
- [x] 5.02 Configurar GoRouter com ShellRoute e StatefulShellRoute (note: GoRouter com ShellRoute e StatefulShellRoute)
- [x] 5.03 Criar MainLayout com AppBar, Drawer e ZoneSelector (note: MainLayout com AppBar, Drawer, ZoneSelector)
- [x] 5.04 Criar SettingsPage com form de token, tema e idioma (note: SettingsPage com form token, tema, idioma)
- [x] 5.05 Criar DnsPage com BottomNavigationBar (3 tabs) (note: DnsPage com BottomNavigationBar 3 tabs)
- [x] 5.06 Criar DnsRecordsPage com filtros, busca, lista e FAB (note: DnsRecordsPage com filtros, busca, lista, FAB)
- [x] 5.07 Criar DnsRecordItem com swipe-to-delete e proxy toggle (note: DnsRecordItem com swipe-to-delete e proxy toggle)
- [x] 5.08 Criar DnsRecordEditDialog com validação (note: DnsRecordEditDialog com validação)
- [x] 5.09 Criar CloudflareProxyToggle customizado (note: CloudflareProxyToggle customizado)
- [x] 5.10 Criar DnsAnalyticsPage com TimeRangeSelector e gráficos (note: DnsAnalyticsPage com TimeRangeSelector e gráficos)
- [x] 5.11 Criar AnalyticsChart com Syncfusion (line, bar, donut) (note: AnalyticsChart com Syncfusion line/bar/donut)
- [x] 5.12 Criar AnalyticsMapChart com SfMaps e markers (note: AnalyticsMapChart com SfMaps e markers)
- [x] 5.13 Criar DnsSettingsPage com DNSSEC state machine (note: DnsSettingsPage com DNSSEC state machine)
- [x] 5.14 Criar DnssecDetailsDialog com campos copiáveis (note: DnssecDetailsDialog com campos copiáveis)
- [x] 5.15 Criar widgets utilitários: SkeletonLoader, ErrorBanner, EmptyState (note: Widgets SkeletonLoader, ErrorBanner, EmptyState)

### Feature 6: Internacionalização (i18n)
Description: Configurar l10n e criar arquivos ARB para inglês e português
- [x] 6.01 Configurar l10n.yaml (note: l10n.yaml configurado)
- [x] 6.02 Criar app_en.arb com todas as strings (note: app_en.arb criado)
- [x] 6.03 Criar app_pt.arb (português brasileiro) (note: app_pt.arb criado)
- [x] 6.04 Strings por módulo: comuns, menu, tabs, DNS, Analytics, Settings, DNSSEC (note: Strings por módulo implementadas)
- [x] 6.05 Configurar formatação de números e datas com intl (note: Formatação números/datas com intl)

### Feature 7: Desktop Support
Description: Configurar window_manager, system tray e keyboard shortcuts
- [x] 7.01 Configurar window_manager: tamanho inicial 1200x800, mínimo 800x600 (note: Window manager 1200x800, mínimo 800x600)
- [x] 7.02 Implementar system tray com menu (Show, Quit) (note: System tray com Show/Quit)
- [x] 7.03 Implementar keyboard shortcuts: Ctrl+S, Ctrl+N, F5, Ctrl+F (note: Shortcuts Ctrl+S/N, F5, Ctrl+F)
- [x] 7.04 Testar em Linux (plataforma dev) (note: Testado em Linux)
- [ ] 7.05 [DEFERRED] Configurar distribuição: AppImage, .exe, .dmg

### Feature 8: PWA Web
Description: Configurar manifest, service worker, install prompt e headers
- [x] 8.01 Configurar web/manifest.json com tema Cloudflare (note: manifest.json com tema Cloudflare configurado)
- [x] 8.02 Flutter web usa flutter_service_worker.js automático (note: Service worker automático do Flutter)
- [ ] 8.03 [DEFERRED] Implementar botão Instalar App no Settings
- [ ] 8.04 [DEFERRED] Criar UpdateBanner para service worker updates
- [x] 8.05 Criar _headers file para Cloudflare Pages (note: _headers para Cloudflare Pages criado)

### Feature 9: Testes
Description: Unit tests para models/API, widget tests para componentes principais
- [x] 9.01 Unit tests para models (fromJson, toJson, copyWith) - 79 tests (note: 79 unit tests para models)
- [x] 9.02 Unit tests para ApiConfig (token validation) - 8 tests (note: 8 tests ApiConfig)
- [x] 9.03 Unit tests para interceptors - 13 tests (note: 13 tests interceptors)
- [x] 9.04 Widget tests CloudflareProxyToggle - 9 tests (note: 9 widget tests CloudflareProxyToggle)
- [x] 9.05 Widget tests DnsRecordItem - 20 tests (note: 20 widget tests DnsRecordItem)
- [ ] 9.06 [DEFERRED] Testes para providers (mock API)
- [ ] 9.07 [DEFERRED] Widget tests com ProviderScope: DnsRecordEditDialog, SettingsPage, ZoneSelector
- [ ] 9.08 [DEFERRED] Integration tests: fluxos completos

### Feature 10: Build & Deploy
Description: Ícones, splash, builds (Android, iOS, Web, Desktop) e CI/CD
- [x] 10.01 Criar ícone e splash screen com flutter_launcher_icons (note: Ícone e splash screen criados)
- [x] 10.02 Build APK release (57.9MB) (note: APK release 57.9MB)
- [x] 10.03 Configurar signing key e build AAB para Play Store (note: upload-keystore.jks + key.properties configurados)
- [ ] 10.04 [DEFERRED] Build iOS (requer macOS)
- [x] 10.05 Build Web com flutter build web --release (note: Web build 33MB com tree-shaken fonts)
- [x] 10.06 Build Linux com flutter build linux --release (note: Linux build 44MB bundle)
- [ ] 10.07 [DEFERRED] Build Windows e macOS
- [x] 10.08 CI/CD: workflow para testes em PRs (note: test.yml workflow criado)
- [x] 10.09 CI/CD: workflow para build Android e Linux (note: build.yml Android + Linux workflow)
- [ ] 10.10 [DEFERRED] CI/CD: workflow para iOS e deploy Cloudflare Pages
