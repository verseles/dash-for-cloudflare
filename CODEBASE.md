# Codebase Map - Dash for Cloudflare

> Mapa do código para navegação rápida. Consulte este arquivo para entender onde cada funcionalidade está implementada.

---

## Estrutura de Diretórios

```
lib/
├── main.dart                    # Entry point, inicialização, ProviderScope
├── core/                        # Código compartilhado
│   ├── api/                     # Cliente HTTP e configuração
│   ├── desktop/                 # Suporte desktop (window, tray, shortcuts)
│   ├── logging/                 # Sistema de logs in-app
│   ├── platform/                # Detecção de plataforma
│   ├── pwa/                     # PWA support (install prompt, update banner)
│   ├── providers/               # Providers globais (API, loading, data centers)
│   ├── router/                  # Configuração go_router
│   ├── theme/                   # Tema Material 3 (light/dark)
│   └── widgets/                 # Widgets reutilizáveis
├── features/                    # Features por domínio
│   ├── auth/                    # Autenticação e configurações
│   ├── dns/                     # Gerenciamento DNS (records, settings, analytics)
│   └── analytics/               # Analytics DNS (GraphQL)
└── l10n/                        # Internacionalização (en, pt)
```

---

## Entry Point

| Arquivo | Responsabilidade |
|---------|------------------|
| `lib/main.dart` | Inicialização do app, LogService, DesktopWindowManager, error handlers, ProviderScope |

---

## Core

### API (`lib/core/api/`)

| Arquivo | Responsabilidade |
|---------|------------------|
| `api_config.dart` | URLs base (com/sem CORS proxy), validação de token |
| `client/cloudflare_api.dart` | Interface Retrofit para REST API |
| `client/cloudflare_graphql.dart` | Cliente GraphQL para analytics |
| `interceptors/auth_interceptor.dart` | Injeta Bearer token em requests |
| `interceptors/retry_interceptor.dart` | Retry automático em falhas |
| `interceptors/rate_limit_interceptor.dart` | Controle de rate limit |
| `interceptors/logging_interceptor.dart` | Log de requests/responses |
| `models/cloudflare_response.dart` | Wrapper de resposta Cloudflare |

### PWA (`lib/core/pwa/`)

| Arquivo | Responsabilidade |
|---------|------------------|
| `pwa_update_service.dart` | Singleton com js_interop para detectar SW updates |
| `pwa_update_provider.dart` | StreamProvider que expõe estado de update disponível |
| `update_banner.dart` | MaterialBanner "Nova versão disponível" com botão atualizar |

**Fluxo:**
1. JS detecta novo service worker → chama `window.notifyFlutterUpdate()`
2. `PwaUpdateService` recebe via js_interop → emite no stream
3. `pwaUpdateAvailableProvider` → UI mostra `UpdateBanner`
4. Usuário clica → `reloadForUpdate()` → `skipWaiting()` + reload

### Desktop (`lib/core/desktop/`)

| Arquivo | Responsabilidade |
|---------|------------------|
| `window_manager.dart` | Tamanho inicial (1200x800), mínimo (800x600) |
| `tray_manager.dart` | System tray com menu (Show/Quit) |
| `keyboard_shortcuts.dart` | Atalhos: Ctrl+S, Ctrl+N, F5, Ctrl+F |

### Logging (`lib/core/logging/`)

| Arquivo | Responsabilidade |
|---------|------------------|
| `log_service.dart` | Singleton de logging, níveis, categorias |
| `log_entry.dart` | Modelo de entrada de log |
| `log_level.dart` | Enum de níveis e categorias |
| `log_provider.dart` | Providers Riverpod para logs |
| `presentation/debug_logs_page.dart` | UI de visualização de logs |

### Providers Globais (`lib/core/providers/`)

| Arquivo | Provider | Responsabilidade |
|---------|----------|------------------|
| `api_providers.dart` | `dioProvider`, `cloudflareApiProvider`, `cloudflareGraphQLProvider` | Instâncias de API |
| `loading_provider.dart` | `loadingProvider` | Estado de loading global |
| `data_centers_provider.dart` | `dataCentersProvider` | Dados de data centers Cloudflare (IATA codes) |

### Router (`lib/core/router/`)

| Arquivo | Responsabilidade |
|---------|------------------|
| `app_router.dart` | Configuração go_router, rotas, redirects, StatefulShellRoute |

**Rotas:**
- `/settings` → SettingsPage (fora do shell)
- `/debug-logs` → DebugLogsPage (fora do shell)
- `/dns/records` → DnsRecordsPage (tab 1)
- `/dns/analytics` → DnsAnalyticsPage (tab 2)
- `/dns/settings` → DnsSettingsPage (tab 3)

### Theme (`lib/core/theme/`)

| Arquivo | Responsabilidade |
|---------|------------------|
| `app_theme.dart` | Temas light/dark, Material 3, cor primária Cloudflare (#F38020) |

### Widgets (`lib/core/widgets/`)

| Arquivo | Responsabilidade |
|---------|------------------|
| `main_layout.dart` | Layout principal com AppBar, Drawer, ZoneSelector |
| `skeleton_loader.dart` | Skeleton loading animation |
| `error_banner.dart` | Banner de erro reutilizável |
| `empty_state.dart` | Estado vazio com ícone e mensagem |
| `loading_overlay.dart` | Overlay de loading |

---

## Features

### Auth (`lib/features/auth/`)

| Caminho | Arquivo | Responsabilidade |
|---------|---------|------------------|
| `models/` | `app_settings.dart` | Model Freezed: token, theme, locale, selectedZoneId |
| `providers/` | `settings_provider.dart` | SettingsNotifier: SecureStorage (token), SharedPreferences (prefs) |
| `presentation/pages/` | `settings_page.dart` | UI de configurações: token, tema, idioma |

**Providers importantes:**
- `settingsNotifierProvider` → Estado de configurações
- `hasValidTokenProvider` → Bool se token é válido (40+ chars)
- `currentThemeModeProvider` → ThemeMode atual
- `currentLocaleProvider` → Locale atual

### DNS (`lib/features/dns/`)

#### Models (`domain/models/`)

| Arquivo | Models |
|---------|--------|
| `zone.dart` | `Zone`, `ZoneRegistrar` |
| `dns_record.dart` | `DnsRecord`, `DnsRecordCreate` |
| `dns_settings.dart` | `DnsSetting`, `DnsZoneSettings`, `DnssecDetails` |

#### Providers (`providers/`)

| Arquivo | Provider | Responsabilidade |
|---------|----------|------------------|
| `zone_provider.dart` | `zonesNotifierProvider` | Lista de zonas com cache (ADR-022) |
| | `selectedZoneNotifierProvider` | Zona atualmente selecionada |
| | `zoneFilterProvider` | Filtro de busca de zonas |
| | `filteredZonesProvider` | Zonas filtradas |
| `dns_records_provider.dart` | `dnsRecordsNotifierProvider` | CRUD de registros DNS com cache |
| `dns_settings_provider.dart` | `dnsSettingsNotifierProvider` | DNSSEC, multi-provider, CNAME flattening |
| `tab_preloader_provider.dart` | `tabPreloaderProvider` | Preload de abas ao mudar zona (ADR-024) |

**Padrões importantes:**
- Cache com background refresh (ADR-022) para zones e records
- Tab preloading ao mudar zona (ADR-024)
- Race condition prevention com `_currentFetchId`
- Optimistic updates para proxy toggle
- DNSSEC polling duplo (3s + 2s)

#### Presentation (`presentation/`)

| Caminho | Arquivo | Responsabilidade |
|---------|---------|------------------|
| `pages/` | `dns_page.dart` | Container com BottomNavigationBar (3 tabs) |
| | `dns_records_page.dart` | Lista de registros, filtros, busca, FAB |
| | `dns_analytics_page.dart` | Gráficos de analytics |
| | `dns_settings_page.dart` | DNSSEC toggle, detalhes, multi-provider |
| `widgets/` | `dns_record_item.dart` | Item de registro com swipe-to-delete |
| | `dns_record_edit_dialog.dart` | Dialog de criar/editar registro |
| | `cloudflare_proxy_toggle.dart` | Toggle customizado (orange cloud) |
| `widgets/charts/` | `analytics_time_series_chart.dart` | Gráfico de linha temporal |
| | `analytics_bar_chart.dart` | Gráfico de barras |
| | `analytics_doughnut_chart.dart` | Gráfico donut |
| | `analytics_map_chart.dart` | Mapa mundi com markers |

### Analytics (`lib/features/analytics/`)

| Caminho | Arquivo | Responsabilidade |
|---------|---------|------------------|
| `domain/models/` | `analytics.dart` | `DnsAnalyticsData`, `AnalyticsGroup`, `AnalyticsTimeSeries` |
| `providers/` | `analytics_provider.dart` | AnalyticsNotifier: fetch, time range, query names |

**Time ranges disponíveis:** 30m, 6h, 12h, 24h, 7d, 30d

---

## Internacionalização (`lib/l10n/`)

| Arquivo | Responsabilidade |
|---------|------------------|
| `app_en.arb` | Strings em inglês (default) |
| `app_pt.arb` | Strings em português |
| `app_localizations.dart` | Gerado automaticamente |

---

## Fluxo de Dados

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   UI/Page   │ ──▶ │   Provider   │ ──▶ │  API Client │
│             │ ◀── │  (Notifier)  │ ◀── │ (Retrofit)  │
└─────────────┘     └──────────────┘     └─────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │    Model     │
                    │  (Freezed)   │
                    └──────────────┘
```

1. **UI** observa providers via `ref.watch()`
2. **Provider** mantém estado e lógica de negócio
3. **API Client** faz requests HTTP (Retrofit/Dio)
4. **Models** são imutáveis (Freezed com sealed classes)

---

## Arquivos Gerados (não commitar)

Padrão: `*.g.dart`, `*.freezed.dart`

- Gerados por `build_runner`
- Listados no `.gitignore`
- Regenerar com `make gen`

---

## Pontos de Atenção

### Race Conditions
- `dns_records_provider.dart:76` → `_currentFetchId` previne respostas stale

### Optimistic Updates
- `dns_records_provider.dart:267` → `updateProxy()` atualiza UI antes da API

### Polling
- `dns_settings_provider.dart:121-125` → DNSSEC polling duplo

### CORS
- `api_config.dart` → Web usa proxy, mobile/desktop usa API direta

### Armazenamento
- Token → `flutter_secure_storage` (criptografado)
- Preferências → `shared_preferences` (não sensível)

---

## Comandos Úteis para Navegação

```bash
# Encontrar todos os providers
grep -r "@riverpod" lib/ --include="*.dart" | grep -v ".g.dart"

# Encontrar todos os models Freezed
grep -r "@freezed" lib/ --include="*.dart" | grep -v ".freezed.dart"

# Encontrar endpoints da API
grep -r "@GET\|@POST\|@PUT\|@PATCH\|@DELETE" lib/ --include="*.dart"

# Encontrar páginas
find lib -name "*_page.dart" -type f
```

---

_Última atualização: 2026-01-02_
