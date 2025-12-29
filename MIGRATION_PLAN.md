# Dash for Cloudflare - Migration Plan (Vue → Flutter)

> **Projeto original Vue/Quasar**: Branch `old_vue` > **Consulte a branch `old_vue` para esclarecer dúvidas não cobertas por este plano.**

## Regras importantes a serem seguidas durante todo o processo de migração

1. Sempre que possível e ao iniciar a sessão, visite o projeto original para esclarecer o funcionamento anterior funcional
2. Se ficar preso em erros, use web search para resolver
3. Para cada web search aguarde 1 segundo após o recebimento da resposta para fazer uma nova pesquisa
4. A cada fase concluída, atualize este documento, faça um commit bem descrito e push e avance para a próxima fase, sem perguntas ou pausas
5. Trabalhe de forma autônoma, sem pausas, apenas commits como checkpoints
6. Sempre monte o to-do list das fases pendentes, e sub fases
7. Se ficar completamente preso sem opções de resolver sozinho, chame a tool play_notification e pare até receber uma resposta do usuário. Mas priorize soluções autônomas.
8. Esse projeto não está em produção, portanto, não é necessário preocupar com compatibilidade com versões anteriores, refatore livremente conforme necessário.
9. Quando chegar na fase de tests ou superior, use-os como gatekeeper para avançar para a próxima fase.
10. Crie novos tests e atualize os existentes conforme necessário para garantir a qualidade do código.

---

## Informações do Projeto

| Campo               | Valor                                    |
| ------------------- | ---------------------------------------- |
| **Nome**            | Dash for Cloudflare                      |
| **Package ID**      | `ad.dash.cf`                             |
| **Web URL**         | `cf.dash.ad`                             |
| **Plataformas**     | Android, iOS, Web, Linux, macOS, Windows |
| **Plataformas Dev** | Android, Linux                           |
| **Repositório**     | github.com/verseles/dash-for-cloudflare  |

---

## Stack Técnica Definida

| Categoria            | Pacote/Tecnologia                     | Termos de Busca                                                           |
| -------------------- | ------------------------------------- | ------------------------------------------------------------------------- |
| **Framework**        | Flutter 3.x                           | `flutter create`, `flutter multi-platform`                                |
| **State Management** | Riverpod 2.x                          | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`           |
| **HTTP Client**      | Dio + Retrofit                        | `dio flutter`, `retrofit flutter`, `retrofit_generator`                   |
| **Routing**          | go_router                             | `go_router flutter`, `ShellRoute`, `StatefulShellRoute`                   |
| **Data Classes**     | Freezed + JSON Serializable           | `freezed flutter`, `json_serializable`, `build_runner`                    |
| **Storage Seguro**   | flutter_secure_storage                | `flutter_secure_storage`, `keychain flutter`                              |
| **Storage Simples**  | shared_preferences                    | `shared_preferences flutter`                                              |
| **Charts**           | Syncfusion Charts (Community License) | `syncfusion_flutter_charts`, `SfCartesianChart`, `SfCircularChart`        |
| **Maps**             | Syncfusion Maps (Community License)   | `syncfusion_flutter_maps`, `SfMaps`, `MapShapeLayer`, `MapBubbleSettings` |
| **i18n**             | flutter_localizations + intl          | `flutter l10n`, `arb files`, `flutter gen-l10n`                           |
| **Desktop**          | window_manager, tray_manager          | `window_manager flutter`, `system tray flutter`                           |
| **PWA**              | pwa_install + Workbox                 | `flutter web pwa`, `workbox service worker`                               |
| **Testes**           | flutter_test, mocktail, patrol        | `flutter test`, `widget test`, `integration_test`                         |

---

## CORS Strategy

| Plataforma  | Precisa Proxy? | URL Base                                                 |
| ----------- | -------------- | -------------------------------------------------------- |
| **Web**     | Sim            | `https://cors.verseles.com/api.cloudflare.com/client/v4` |
| **Android** | Não            | `https://api.cloudflare.com/client/v4`                   |
| **iOS**     | Não            | `https://api.cloudflare.com/client/v4`                   |
| **Desktop** | Não            | `https://api.cloudflare.com/client/v4`                   |

**Detecção**: Usar `kIsWeb` do Flutter para detectar plataforma web.

---

## Telas a Implementar

| #   | Tela             | Rota             | Descrição                                |
| --- | ---------------- | ---------------- | ---------------------------------------- |
| 1   | MainLayout       | Shell            | Layout principal com Drawer e AppBar     |
| 2   | SettingsPage     | `/settings`      | API Token, Tema, Idioma                  |
| 3   | DnsPage          | `/dns`           | Container com BottomNavigationBar        |
| 4   | DnsRecordsPage   | `/dns/records`   | CRUD de registros DNS                    |
| 5   | DnsAnalyticsPage | `/dns/analytics` | Dashboard com gráficos                   |
| 6   | DnsSettingsPage  | `/dns/settings`  | DNSSEC, Multi-provider, CNAME Flattening |

---

## Componentes a Implementar

| Componente            | Descrição                          | Termos de Busca                                                               |
| --------------------- | ---------------------------------- | ----------------------------------------------------------------------------- |
| ZoneSelector          | Dropdown com autocomplete de zonas | `Autocomplete flutter`, `DropdownButton`                                      |
| DnsRecordItem         | Item de lista com swipe-to-delete  | `Dismissible flutter`, `ListTile`                                             |
| DnsRecordEditDialog   | Dialog para criar/editar registros | `showDialog`, `AlertDialog`, `Form`                                           |
| CloudflareProxyToggle | Toggle com ícone de cloud          | `Switch flutter`, `custom toggle`                                             |
| DnssecDetailsDialog   | Modal com detalhes DS record       | `showDialog`, `copyToClipboard`                                               |
| AnalyticsChart        | Gráficos line/bar/pie              | `SfCartesianChart`, `SfCircularChart`, `LineSeries`, `BarSeries`, `PieSeries` |
| AnalyticsMapChart     | Mapa mundi com bubbles             | `SfMaps`, `MapShapeLayer`, `MapBubbleSettings`                                |
| TimeRangeSelector     | Seletor de período (30m a 30d)     | `SegmentedButton`, `ToggleButtons`                                            |
| SkeletonLoader        | Loading placeholder                | `shimmer flutter`, `Skeleton`                                                 |

---

## Fase 1: Setup do Projeto ✅

### 1.1 Criar Projeto Flutter

- [x] Executar `flutter create` com plataformas: android, ios, web, linux, macos, windows
- [x] Configurar package name: `ad.dash.cf`
- [x] Configurar nome do app: "Dash for Cloudflare"

### 1.2 Estrutura de Pastas

- [x] Criar estrutura feature-based: `lib/features/`, `lib/core/`, `lib/shared/`
- [x] Criar pasta `lib/features/auth/` para settings
- [x] Criar pasta `lib/features/dns/` para DNS records, analytics, settings
- [x] Criar pasta `lib/features/analytics/` para analytics específicos
- [x] Criar pasta `lib/core/theme/` para temas light/dark
- [x] Criar pasta `lib/core/platform/` para detecção de plataforma e CORS
- [x] Criar pasta `lib/core/widgets/` para widgets reutilizáveis
- [x] Criar pasta `lib/l10n/` para internacionalização
- [x] Criar pasta `assets/data/` para world.json e cloudflare-iata-full.json
- [x] Criar pasta `assets/icons/` para ícones

### 1.3 Dependências (pubspec.yaml)

- [x] Adicionar flutter_riverpod e riverpod_annotation
- [x] Adicionar dio e retrofit
- [x] Adicionar go_router
- [x] Adicionar freezed_annotation e json_annotation
- [x] Adicionar flutter_secure_storage e shared_preferences
- [x] Adicionar syncfusion_flutter_charts e syncfusion_flutter_maps
- [x] Adicionar window_manager e tray_manager
- [x] Adicionar pwa_install
- [x] Adicionar intl e flutter_localizations
- [x] Adicionar dev_dependencies: build_runner, freezed, json_serializable, riverpod_generator, retrofit_generator
- [x] Adicionar dev_dependencies: mocktail, patrol
- [x] Adicionar flutter_launcher_icons e flutter_native_splash

### 1.4 Configurações Iniciais

- [x] Configurar analysis_options.yaml
- [x] Configurar l10n.yaml para internacionalização
- [x] Criar .gitignore adequado para Flutter
- [ ] Registrar Syncfusion Community License key (não necessário para desenvolvimento)

---

## Fase 2: Modelos de Dados ✅

### 2.1 Models Core (com Freezed)

- [x] Criar model `Zone` (id, name, status, registrar)
- [x] Criar model `ZoneRegistrar` (id, name)
- [x] Criar model `DnsRecord` (id, type, name, content, proxied, ttl, zoneId, zoneName)
- [x] Criar model `DnsRecordCreate` (para POST/PUT requests)
- [x] Criar model `DnsSetting` (id, value, editable, modifiedOn)
- [x] Criar model `DnsZoneSettings` (multiProvider)
- [x] Criar model `DnssecDetails` (status, ds, digest, algorithm, publicKey, keyTag, flags, etc.)
- [x] Criar model `AppSettings` (cloudflareApiToken, themeMode, locale)

### 2.2 Models Analytics

- [x] Criar model `DnsAnalyticsData` (total, timeSeries, byQueryName, byRecordType, etc.)
- [x] Criar model `AnalyticsGroup` (count, dimensions)
- [x] Criar model `DataCenterInfo` (place, lat, lng)

### 2.3 Models API Response

- [x] Criar model `CloudflareResponse<T>` (result, success, errors, messages)
- [x] Criar model `CloudflareError` (code, message)
- [x] Criar model `DeleteResponse` (id)

### 2.4 Gerar Código

- [x] Executar `dart run build_runner build --delete-conflicting-outputs`
- [x] Verificar arquivos .freezed.dart e .g.dart gerados

---

## Fase 3: Camada de API ✅

### 3.1 Configuração Base

- [x] Criar `ApiConfig` com URLs base (com e sem proxy CORS)
- [x] Criar `PlatformDetector` para detectar web vs nativo
- [x] Implementar lógica de seleção de URL baseada na plataforma

### 3.2 Interceptors Dio

- [x] Criar `AuthInterceptor` para adicionar Bearer token
- [x] Criar `RetryInterceptor` com exponential backoff (429, 5xx)
- [x] Criar `RateLimitInterceptor` para monitorar headers X-RateLimit-\*
- [x] Criar `LogInterceptor` para debug mode

### 3.3 REST API Client (Retrofit)

- [x] Criar interface `CloudflareApi` com anotações Retrofit
- [x] Implementar endpoint GET /zones com `per_page=100` (padrão da API é 20)
- [x] Implementar endpoints CRUD /zones/{zoneId}/dns_records
- [x] Implementar endpoints GET/PATCH /zones/{zoneId}/dnssec
- [x] Implementar endpoints GET/PATCH /zones/{zoneId}/settings
- [x] Implementar endpoints GET/PATCH /zones/{zoneId}/dns_settings

### 3.4 GraphQL Client

- [x] Criar classe `CloudflareGraphQL` para analytics
- [x] Implementar query principal de analytics (7 grupos)
- [x] Implementar queries paralelas por query name
- [x] Parsear resposta GraphQL para DnsAnalyticsData

### 3.5 Providers de API

- [x] Criar provider `dioProvider`
- [x] Criar provider `cloudflareApiProvider`
- [x] Criar provider `cloudflareGraphQLProvider`

### 3.6 Gerar Código Retrofit

- [x] Executar build_runner para gerar \_CloudflareApi

---

## Fase 4: State Management (Riverpod) ✅

### 4.1 Settings Provider

- [x] Criar `SettingsNotifier` com FlutterSecureStorage e SharedPreferences
- [x] Implementar load/save de API token (SecureStorage)
- [x] Implementar load/save de tema (SharedPreferences)
- [x] Implementar load/save de idioma (SharedPreferences)
- [x] Validar token (mínimo 40 caracteres)

### 4.2 Zone Provider

- [x] Criar `ZonesNotifier` para lista de zonas
- [x] Criar `SelectedZoneNotifier` para zona selecionada
- [x] Persistir zona selecionada em SharedPreferences
- [x] Auto-selecionar primeira zona se nenhuma selecionada

### 4.3 DNS Records Provider

- [x] Criar `DnsRecordsNotifier` (family por zoneId)
- [x] Implementar fetchRecords com race condition prevention
- [x] Implementar saveRecord (create ou update)
- [x] Implementar deleteRecord
- [x] Implementar updateProxy (optimistic update)

### 4.4 DNS Settings Provider

- [x] Criar `DnsSettingsNotifier`
- [x] Implementar fetch de DNSSEC status
- [x] Implementar toggle DNSSEC (enable/disable)
- [x] Implementar toggle multi-signer DNSSEC
- [x] Implementar toggle multi-provider DNS
- [x] Implementar toggle CNAME flattening
- [x] Implementar polling de status após mudanças

### 4.5 Analytics Provider

- [x] Criar `AnalyticsNotifier` (family por zoneId)
- [x] Implementar fetchAnalytics com time range
- [x] Implementar fetch por query names selecionados
- [x] Gerenciar loading/error states

### 4.6 Loading Provider

- [x] Criar `LoadingNotifier` para múltiplas operações
- [x] Implementar startLoading/stopLoading por operationId
- [x] Implementar isAnyLoading computed

### 4.7 Data Centers Provider

- [x] Criar `DataCentersNotifier`
- [x] Carregar cloudflare-iata-full.json do assets como fallback imediato
- [x] Buscar versão atualizada do CDN em background (`https://cdn.jsdelivr.net/gh/insign/Cloudflare-Data-Center-IATA-Code-list/cloudflare-iata-full.json`)
- [x] Implementar flag `hasFetched` para evitar refetch em cada mount
- [x] Mapear IATA codes para lat/lng

---

## Fase 5: UI/Widgets ✅

### 5.1 Tema e Cores

- [x] Criar `AppTheme` com light e dark themes
- [x] Definir color scheme baseado em Cloudflare (laranja #F38020)
- [x] Configurar Material 3 (useMaterial3: true)

### 5.2 Routing (go_router)

- [x] Configurar GoRouter com rotas
- [x] Implementar ShellRoute para MainLayout
- [x] Implementar StatefulShellRoute para DNS tabs
- [x] Implementar redirect guard condicional:
  - Sem token salvo → redireciona para `/settings`
  - Com token salvo → redireciona `/` para `/dns/records`
- [x] Bloquear acesso a `/dns/*` sem token válido

### 5.3 MainLayout

- [x] Criar Scaffold com AppBar
- [x] Implementar Drawer com menu de navegação
- [x] Implementar ZoneSelector no AppBar (autocomplete)
- [x] Auto-selecionar zona quando filtro retornar apenas 1 resultado
- [x] Mostrar loading indicator global
- [x] Condicional: mostrar ZoneSelector apenas em rotas /dns/\*

### 5.4 SettingsPage

- [x] Criar form com TextField para API token (obscured)
- [x] Validar token (40+ chars) com mensagem de erro
- [x] Adicionar texto de ajuda com permissões necessárias
- [x] Adicionar link para criar token no Cloudflare
- [x] Implementar seletor de tema (Light/Auto/Dark) com SegmentedButton
- [x] Implementar seletor de idioma (Dropdown)
- [x] Botão "Ir para DNS" (aparece após token válido)

### 5.5 DnsPage (Container com Tabs)

- [x] Implementar BottomNavigationBar com 3 tabs
- [x] Tab 1: Records (icon: dns)
- [x] Tab 2: Analytics (icon: analytics)
- [x] Tab 3: Settings (icon: settings)
- [x] Usar StatefulShellRoute para preservar estado dos tabs

### 5.6 DnsRecordsPage

- [x] Criar toolbar com chips de filtro (All, A, AAAA, CNAME, TXT, MX, etc.)
- [x] Implementar scroll horizontal nos chips
- [x] Criar campo de busca expansível
- [x] Implementar lista de DnsRecordItem
- [x] Manter Sets de IDs por estado: saving, new, deleting
- [x] Implementar delay de ~1200ms antes de executar delete (permite ver animação)
- [x] Limpar newRecordIds após 2000ms da animação
- [x] Implementar skeleton loaders (5 itens)
- [x] Implementar empty state com mensagem
- [x] Criar FAB para adicionar registro
- [x] Implementar pull-to-refresh

### 5.7 DnsRecordItem

- [x] Usar Dismissible para swipe-to-delete
- [x] Mostrar Chip com tipo (A, AAAA, etc.)
- [x] Mostrar nome (sem sufixo de zona, @ para root)
- [x] Mostrar content em monospace
- [x] Mostrar TTL (ou "Auto" se 1)
- [x] Mostrar CloudflareProxyToggle (apenas A/AAAA/CNAME)
- [x] Animação de highlight para novo registro
- [x] Animação de pulse vermelho para deletando

### 5.8 DnsRecordEditDialog

- [x] Criar dialog com Form
- [x] Dropdown para tipo (disabled se editando)
- [x] TextField para name
- [x] TextField/TextArea para content (3 linhas para TXT)
- [x] Dropdown para TTL (Auto, 1min, 5min, etc.)
- [x] CloudflareProxyToggle (apenas A/AAAA/CNAME)
- [x] Placeholders dinâmicos baseados no tipo
- [x] Validação de campos obrigatórios
- [x] Botões Cancel e Save/Create

### 5.9 CloudflareProxyToggle

- [x] Criar Switch customizado
- [x] Ícone de cloud quando ativo
- [x] Cor laranja quando ativo, cinza quando inativo
- [x] Tooltip explicativo

### 5.10 DnsAnalyticsPage

- [x] Implementar TimeRangeSelector (30m, 6h, 12h, 24h, 7d, 30d)
- [x] Card de Overview com badges clicáveis (Total + Top 5 query names)
- [x] Limitar seleção de query names a máximo 5 simultâneos
- [x] Gráfico de linha (time series)
- [x] Suporte a múltiplas séries (quando query names selecionados)
- [x] Painel de estatísticas (Total, Avg QPS, Avg Processing Time)
- [x] Grid 2x3 com 6 cards de gráficos
- [x] Chart: Queries by Data Center (doughnut)
- [ ] Chart: Queries by Location (mapa mundi com bubbles) - **DEFERRED: Syncfusion Maps implementation**
- [x] Chart: Queries by Record Type (bar vertical)
- [x] Chart: Queries by Response Code (doughnut)
- [x] Chart: Queries by IP Version (doughnut)
- [x] Chart: Queries by Protocol (doughnut)

### 5.11 AnalyticsChart (Syncfusion Charts)

- [x] Criar widget reusável usando `SfCartesianChart` para line/bar
- [x] Criar widget reusável usando `SfCircularChart` para pie/donut
- [x] Usar `LineSeries`, `BarSeries`, `ColumnSeries`, `DoughnutSeries`
- [x] Suportar theming (cores light/dark)
- [x] Implementar tooltips com `TooltipBehavior`
- [x] Implementar responsive sizing

### 5.12 AnalyticsMapChart (Syncfusion Maps)

- [ ] Usar `SfMaps` com `MapShapeLayer` - **DEFERRED to Phase 7 (Desktop)**
- [ ] Carregar world.json como GeoJSON via `MapShapeSource.asset`
- [ ] Implementar bubble layer com `MapBubbleSettings` para data centers
- [ ] Mapear IATA codes para coordenadas
- [ ] Implementar tooltips com `MapTooltipSettings`
- [ ] Responsive sizing

### 5.13 DnsSettingsPage

- [x] Card DNSSEC com state machine visual
- [x] Estado disabled: botão Enable, descrição
- [x] Estado pending: info DS record, botão Cancel
- [x] Estado pending (CF Registrar): mensagem especial
- [x] Estado active: sucesso, botão Disable, botão Ver Detalhes
- [x] Estado pending-disabled: botão cancelar deleção
- [x] Toggle Multi-signer DNSSEC
- [x] Toggle Multi-provider DNS
- [x] Toggle CNAME Flattening
- [x] Card Email Security (placeholder, botão mostra toast "Work in Progress")
- [x] Dialogs de confirmação para ações destrutivas

### 5.14 DnssecDetailsDialog

- [x] Mostrar campos: DS Record, Digest, Digest Type, Algorithm, Public Key, Key Tag, Flags
- [x] Cada campo clicável para copiar
- [x] Feedback visual ao copiar (snackbar)

### 5.15 Widgets Utilitários

- [x] Criar SkeletonLoader genérico
- [x] Criar ErrorBanner para erros de API
- [x] Criar LoadingOverlay
- [x] Criar EmptyState com ícone e mensagem

---

## Fase 6: Internacionalização (i18n) ✅

### 6.1 Configuração

- [x] Configurar l10n.yaml
- [x] Criar app_en.arb com todas as strings
- [x] Criar app_pt.arb (português brasileiro)

### 6.2 Strings por Módulo

- [x] Strings comuns: ok, cancel, save, delete, error, loading, workInProgress
- [x] Strings de menu: dns, settings
- [x] Strings de tabs: records, analytics, settings
- [x] Strings de DNS: zoneSelector, noRecords, noRecordsMatch, editRecord, deleteConfirm
- [x] Strings de Analytics: timeRanges, chartTitles, noData
- [x] Strings de Settings: apiToken, theme, language, permissions
- [x] Strings de DNSSEC: estados, ações, avisos
- [x] Strings de Email Security: title, description, configureBtn
- [x] Strings de PWA Update: newVersionAvailable, updateNow
- [x] Strings de toasts: recordSaved, recordDeleted, copied, copyError, error messages

### 6.3 Formatação

- [x] Configurar formatação de números (intl)
- [x] Configurar formatação de datas/horas
- [x] Pluralização onde necessário

---

## Fase 7: Desktop Support ✅

### 7.1 Window Manager

- [x] Configurar tamanho inicial (1200x800)
- [x] Configurar tamanho mínimo (800x600)
- [x] Configurar título da janela
- [x] Centralizar janela ao abrir

### 7.2 System Tray

- [x] Criar ícone de tray (PNG para Linux/macOS, ICO para Windows)
- [x] Implementar menu de contexto: Show, Separator, Quit
- [x] Handler para click no ícone (mostrar janela)
- [x] Handler para menu items

### 7.3 Keyboard Shortcuts

- [x] Ctrl/Cmd+S para salvar
- [x] Ctrl/Cmd+N para novo registro
- [x] F5 para refresh
- [x] Ctrl/Cmd+F para busca

### 7.4 Platform-Specific

- [x] Testar em Linux (plataforma dev)
- [ ] Configurar AppImage ou .deb para distribuição Linux - **DEFERRED to Phase 10**
- [ ] Configurar .exe installer para Windows - **DEFERRED to Phase 10**
- [ ] Configurar .dmg para macOS - **DEFERRED to Phase 10**

---

## Fase 8: PWA Web ✅

### 8.1 Manifest

- [x] Configurar web/manifest.json
- [x] Nome: "Dash for Cloudflare"
- [x] Short name: "CF Dash"
- [x] Theme color: #F38020 (laranja Cloudflare)
- [x] Display: standalone
- [x] Ícones: 192x192 e 512x512
- [x] Adicionados shortcuts para DNS

### 8.2 Service Worker

- [x] Flutter web usa flutter_service_worker.js automático
- [x] Caching de assets incluído no build

### 8.3 Install Prompt

- [x] pwa_install package já adicionado no pubspec.yaml
- [ ] Implementar botão "Instalar App" no Settings - **DEFERRED** (funcionalidade básica ok)
- [ ] Detectar se já está instalado - **DEFERRED**

### 8.4 Update Banner

- [ ] Criar componente `UpdateBanner` - **DEFERRED** (service worker updates automáticos)

### 8.5 Headers para Deploy

- [x] Criar \_headers file para Cloudflare Pages
- [ ] Configurar COOP/COEP para WASM multi-threading - **DEFERRED** (flutter_secure_storage_web usa dart:html)
- [x] Configurar cache headers
- [x] Configurar security headers

---

## Fase 9: Testes ✅

### 9.1 Unit Tests ✅

- [x] Testes para models (fromJson, toJson, copyWith) - 79 tests
  - Zone, ZoneRegistrar (11 tests)
  - DnsRecord, DnsRecordCreate (12 tests)
  - DnsSetting, DnsZoneSettings, DnssecDetails (13 tests)
  - DnsAnalyticsData, AnalyticsTimeSeries, AnalyticsGroup, DataCenterInfo (14 tests)
  - CloudflareResponse, CloudflareError, CloudflareMessage, CloudflareResultInfo, DeleteResponse (12 tests)
  - AppSettings, ThemeModeConverter (18 tests)
- [x] Testes para ApiConfig (token validation) - 8 tests
- [x] Testes para interceptors - 13 tests
  - AuthInterceptor (5 tests)
  - RateLimitInterceptor (8 tests)
- [ ] Testes para providers (mock API) - **DEFERRED** (requires more mock setup)

### 9.2 Widget Tests ✅

- [x] Teste CloudflareProxyToggle (loading, toggle, tooltip, colors) - 9 tests
- [x] Teste DnsRecordItem (display, TTL formatting, proxy toggle, swipe-to-delete) - 20 tests
- [ ] Teste DnsRecordEditDialog (validação, submit) - **DEFERRED** (requires ProviderScope setup)
- [ ] Teste SettingsPage (form validation) - **DEFERRED** (requires ProviderScope setup)
- [ ] Teste ZoneSelector (search, select) - **DEFERRED** (requires ProviderScope setup)

### 9.3 Integration Tests

- [ ] Fluxo completo: Settings → DNS Records → Create → Edit → Delete - **DEFERRED** (requires device/emulator)
- [ ] Fluxo: Settings → Analytics → Time Range → Charts - **DEFERRED** (requires device/emulator)
- [ ] Fluxo: Settings → DNS Settings → DNSSEC toggle - **DEFERRED** (requires device/emulator)

### 9.4 Golden Tests (opcional)

- [ ] Screenshots de páginas principais - **DEFERRED**
- [ ] Comparação visual light vs dark theme - **DEFERRED**

### Test Summary

**Total: 130 tests passing**
- Unit tests: 100 (models: 79, API: 21)
- Widget tests: 30 (CloudflareProxyToggle: 9, DnsRecordItem: 20, placeholder: 1)

Run all tests: `flutter test test/`

---

## Fase 10: Build & Deploy

### 10.1 Ícones e Splash

- [ ] Criar ícone do app (usar flutter_launcher_icons)
- [ ] Criar splash screen (usar flutter_native_splash)
- [ ] Ícone: baseado no ícone atual do projeto Vue

### 10.2 Build Android

- [ ] Configurar signing key
- [ ] Build APK release
- [ ] Build App Bundle (AAB) para Play Store
- [ ] Testar em dispositivo físico

### 10.3 Build iOS

- [ ] Configurar certificates e provisioning profiles
- [ ] Build IPA
- [ ] Testar em simulador
- [ ] Testar em dispositivo físico (se disponível)

### 10.4 Build Web

- [ ] Build com `flutter build web --wasm --release`
- [ ] Testar localmente
- [ ] Configurar Cloudflare Pages
- [ ] Deploy para cf.dash.ad

### 10.5 Build Desktop

- [ ] Build Linux: `flutter build linux --release`
- [ ] Testar no sistema local
- [ ] Build Windows (se disponível)
- [ ] Build macOS (se disponível)

### 10.6 CI/CD (GitHub Actions)

- [ ] Workflow para testes em PRs
- [ ] Workflow para build Android
- [ ] Workflow para build iOS
- [ ] Workflow para build Web + deploy Cloudflare Pages
- [ ] Workflow para build Desktop (matrix: linux, windows, macos)

---

## Assets a Migrar

| Arquivo Original                       | Destino Flutter                         | Descrição                |
| -------------------------------------- | --------------------------------------- | ------------------------ |
| `src/assets/world.json`                | `assets/data/world.json`                | GeoJSON para mapa mundi  |
| `src/assets/cloudflare-iata-full.json` | `assets/data/cloudflare-iata-full.json` | Coordenadas data centers |
| `src/assets/icon.png`                  | `assets/icons/icon.png`                 | Ícone base para geração  |
| `src/assets/orange-cloud.png`          | `assets/icons/cloud.png`                | Ícone de cloud           |

---

## APIs Cloudflare Utilizadas

### REST API (Base: api.cloudflare.com/client/v4)

| Método | Endpoint                         | Descrição              |
| ------ | -------------------------------- | ---------------------- |
| GET    | /zones                           | Listar zonas           |
| GET    | /zones/{zoneId}/dns_records      | Listar registros DNS   |
| POST   | /zones/{zoneId}/dns_records      | Criar registro DNS     |
| PUT    | /zones/{zoneId}/dns_records/{id} | Atualizar registro DNS |
| DELETE | /zones/{zoneId}/dns_records/{id} | Deletar registro DNS   |
| GET    | /zones/{zoneId}/dnssec           | Obter status DNSSEC    |
| PATCH  | /zones/{zoneId}/dnssec           | Atualizar DNSSEC       |
| GET    | /zones/{zoneId}/settings         | Listar settings        |
| PATCH  | /zones/{zoneId}/settings/{id}    | Atualizar setting      |
| GET    | /zones/{zoneId}/dns_settings     | Obter DNS settings     |
| PATCH  | /zones/{zoneId}/dns_settings     | Atualizar DNS settings |

### GraphQL API (Endpoint: api.cloudflare.com/client/v4/graphql)

| Query                      | Descrição                        |
| -------------------------- | -------------------------------- |
| dnsAnalyticsAdaptiveGroups | Analytics agregados por dimensão |

**Dimensões usadas**: datetimeFifteenMinutes, queryName, queryType, responseCode, coloName, ipVersion, protocol

---

## Referências Úteis

| Tópico                 | Link/Termo de Busca                                                                 |
| ---------------------- | ----------------------------------------------------------------------------------- |
| Flutter Riverpod       | `riverpod.dev`, `flutter riverpod tutorial 2025`                                    |
| go_router              | `pub.dev/packages/go_router`, `go_router nested navigation`                         |
| Freezed                | `pub.dev/packages/freezed`, `freezed flutter tutorial`                              |
| Dio + Retrofit         | `pub.dev/packages/retrofit`, `retrofit flutter example`                             |
| Syncfusion Charts      | `pub.dev/packages/syncfusion_flutter_charts`, `SfCartesianChart`, `SfCircularChart` |
| Syncfusion Maps        | `pub.dev/packages/syncfusion_flutter_maps`, `SfMaps`, `MapBubbleSettings`           |
| Flutter Secure Storage | `pub.dev/packages/flutter_secure_storage`                                           |
| Window Manager         | `pub.dev/packages/window_manager`, `flutter desktop window`                         |
| Flutter PWA            | `flutter web pwa 2025`, `workbox flutter`                                           |
| Cloudflare API         | `developers.cloudflare.com/api`, `cloudflare api v4`                                |

---

## Detalhes de Implementação

### Race Condition Prevention

Implementar contador incremental em todos os fetches assíncronos para evitar respostas obsoletas:

```dart
// Em DnsRecordsNotifier
int _currentFetchId = 0;

Future<void> fetchRecords(String zoneId) async {
  final fetchId = ++_currentFetchId;
  state = AsyncLoading();

  try {
    final records = await _api.getDnsRecords(zoneId);
    // Só aplica se ainda for a request mais recente
    if (_currentFetchId == fetchId) {
      state = AsyncData(records);
    }
  } catch (e) {
    if (_currentFetchId == fetchId) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
```

### Zone Auto-Seleção

| Situação                            | Comportamento                     |
| ----------------------------------- | --------------------------------- |
| Zona salva não existe mais na API   | Selecionar primeira zona da lista |
| Filtro de busca retorna 1 resultado | Auto-selecionar essa zona         |
| Nenhuma zona salva                  | Selecionar primeira zona          |

### Cloudflare Registrar Detection

Verificar `zone.registrar?.name == 'cloudflare'` para:

- **É CF Registrar**: Mostrar mensagem "DS record será adicionado automaticamente", sem modal de cópia
- **Não é CF Registrar**: Mostrar modal com DS record para copiar manualmente ao registrador

### DNSSEC Polling

Após qualquer mudança de status DNSSEC, fazer polling duplo:

```dart
await updateDnssec(...);
await Future.delayed(Duration(seconds: 3));
await fetchSettings();
await Future.delayed(Duration(seconds: 2));
await fetchSettings();
```

### Filter Behaviors

1. **Reset on zone change**: Ao trocar zona, resetar `activeFilter = 'All'` e `searchQuery = ''`
2. **Auto-adjust filter**: Se tipo selecionado não existe nos registros filtrados, voltar para 'All'

---

## Constantes

### Record Types

```dart
const recordTypes = ['A', 'AAAA', 'CNAME', 'TXT', 'MX', 'SRV', 'NS', 'PTR'];
```

### TTL Options

```dart
const ttlOptions = [
  (label: 'Auto', value: 1),
  (label: '2 minutes', value: 120),
  (label: '5 minutes', value: 300),
  (label: '10 minutes', value: 600),
  (label: '15 minutes', value: 900),
  (label: '30 minutes', value: 1800),
  (label: '1 hour', value: 3600),
  (label: '2 hours', value: 7200),
  (label: '5 hours', value: 18000),
  (label: '12 hours', value: 43200),
  (label: '1 day', value: 86400),
];
```

### Content Placeholders

```dart
const contentPlaceholders = {
  'A': '192.168.1.1',
  'AAAA': '2001:db8::1',
  'CNAME': 'example.com',
  'TXT': '"v=spf1 include:_spf.google.com ~all"',
  'MX': 'mail.example.com',
  'SRV': '10 5 443 target.example.com',
  'NS': 'ns1.example.com',
  'PTR': 'example.com',
};
```

### Analytics Colors

```dart
const analyticsColors = [
  Color(0xFF1E88E5), // Blue
  Color(0xFFF57C00), // Orange
  Color(0xFF43A047), // Green
  Color(0xFFE91E63), // Pink
  Color(0xFF9C27B0), // Purple
  Color(0xFF00ACC1), // Cyan
  Color(0xFFFDD835), // Yellow
  Color(0xFFE53935), // Red
  Color(0xFF5E35B1), // Deep Purple
  Color(0xFF00897B), // Teal
];
```

---

## Models Completos

### Zone (com registrar)

```dart
@freezed
sealed class Zone with _$Zone {
  const factory Zone({
    required String id,
    required String name,
    required String status,
    ZoneRegistrar? registrar,
  }) = _Zone;

  factory Zone.fromJson(Map<String, dynamic> json) => _$ZoneFromJson(json);
}

@freezed
sealed class ZoneRegistrar with _$ZoneRegistrar {
  const factory ZoneRegistrar({
    required String id,
    required String name,
  }) = _ZoneRegistrar;

  factory ZoneRegistrar.fromJson(Map<String, dynamic> json) => _$ZoneRegistrarFromJson(json);
}
```

### DnssecDetails (campos completos)

```dart
@freezed
sealed class DnssecDetails with _$DnssecDetails {
  const factory DnssecDetails({
    required String status,
    @JsonKey(name: 'dnssec_multi_signer') bool? dnssecMultiSigner,
    String? algorithm,
    String? digest,
    @JsonKey(name: 'digest_algorithm') String? digestAlgorithm,
    @JsonKey(name: 'digest_type') String? digestType,
    String? ds,
    int? flags,
    @JsonKey(name: 'key_tag') int? keyTag,
    @JsonKey(name: 'key_type') String? keyType,
    @JsonKey(name: 'modified_on') String? modifiedOn,
    @JsonKey(name: 'public_key') String? publicKey,
  }) = _DnssecDetails;

  factory DnssecDetails.fromJson(Map<String, dynamic> json) => _$DnssecDetailsFromJson(json);
}
```

---

## Comportamentos de UI

### Search Input Expansível

- Estado inicial: apenas ícone de busca
- Ao clicar: expande para TextField com autofocus
- Ao perder foco com texto vazio: colapsa para ícone
- Ao perder foco com texto: mantém expandido

### DNS Record Name Display

| Condição                      | Display                           |
| ----------------------------- | --------------------------------- |
| `name == zoneName`            | `@`                               |
| `name.endsWith('.$zoneName')` | Nome sem sufixo + sufixo em cinza |
| Caso contrário                | Nome completo                     |

Exemplo: Para zona `example.com`:

- `example.com` → `@`
- `www.example.com` → `www` + `.example.com` (cinza)
- `mail.other.com` → `mail.other.com`

### Time Series Labels

| Time Range        | Formato             |
| ----------------- | ------------------- |
| 30m, 6h, 12h, 24h | `HH:mm` (ex: 14:30) |
| 7d, 30d           | `DD/MM` (ex: 29/12) |

### Merge de Timestamps (Múltiplas Séries)

Ao plotar múltiplas séries (Total + query names selecionados):

1. Coletar todos timestamps únicos de todas as séries
2. Ordenar cronologicamente
3. Para cada série, mapear dados para timestamps (usar 0 se timestamp não existir na série)

```dart
// Exemplo
final allTimestamps = <String>{};
for (final series in allSeries) {
  allTimestamps.addAll(series.map((e) => e.timestamp));
}
final sortedTimestamps = allTimestamps.toList()..sort();

// Para cada série, criar array alinhado com timestamps
final alignedData = sortedTimestamps.map((ts) =>
  series.firstWhere((e) => e.timestamp == ts, orElse: () => 0)
).toList();
```

---

## Notas Importantes

1. **CORS**: Web precisa de proxy (`cors.verseles.com`), mobile/desktop não.

2. **SecureStorage**: Usado apenas para API token. Tema e idioma usam SharedPreferences.

3. **Syncfusion License**: Community License gratuita para <$1M receita. Registrar em syncfusion.com/products/communitylicense. **Nota**: Pacotes Flutter funcionam sem chave no código - a licença é apenas requisito legal.

4. **Branch old_vue**: Contém todo o código Vue original. Consultar para:

   - Lógica de negócio detalhada
   - Estrutura de i18n completa
   - Estilos e cores específicos
   - Edge cases não documentados aqui

5. **Optimistic Updates**: Atualizar UI imediatamente, fazer rollback se API falhar.

6. **Version Pinning**: retrofit pinado em 4.6.0 por incompatibilidade com retrofit_generator 9.7.0 (versões mais novas têm `Parser.DartMappable` não suportado).

7. **Freezed 3.x**: Usa sintaxe `sealed class` para melhor suporte a pattern matching no Dart 3.

---

_Última atualização: 2025-12-29_
