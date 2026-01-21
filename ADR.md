# Architecture Decision Records (ADR)

> Decisões técnicas relevantes para o projeto Dash for Cloudflare (Flutter).
> Consulte este documento ao iniciar novas sessões de desenvolvimento.

---

## ADR-001: Retrofit pinado em versão 4.6.0

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: Ao usar versões mais recentes do retrofit (>4.6.0) com retrofit_generator 9.7.0, ocorre erro `Parser.DartMappable` não suportado durante code generation.

**Decisão**: Pinar retrofit em 4.6.0 no pubspec.yaml.

**Consequência**: Funciona corretamente com build_runner. Não atualizar retrofit sem testar compatibilidade com retrofit_generator.

```yaml
retrofit: 4.6.0  # Pinned - incompatibility with newer versions
```

---

## ADR-003: CORS Proxy apenas para Web

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: Cloudflare API não permite CORS de origens arbitrárias. Browsers bloqueiam requests.

**Decisão**: 
- Web usa proxy: `https://cors.verseles.com/api.cloudflare.com/client/v4`
- Android/iOS/Desktop usam API direta: `https://api.cloudflare.com/client/v4`
- Detecção via `kIsWeb` do Flutter

**Consequência**: Manter proxy funcional para web. Mobile/desktop funcionam sem dependência externa.

---

## ADR-006: Syncfusion Charts/Maps (Community License)

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: Alternativas open-source (fl_chart, charts_flutter) têm menos features. Syncfusion oferece Community License gratuita para <$1M receita.

**Decisão**: Usar syncfusion_flutter_charts e syncfusion_flutter_maps.

**Consequência**: 
- Não precisa de license key no código (funciona sem)
- Registrar em syncfusion.com/products/communitylicense para compliance legal
- Features avançadas disponíveis (SfMaps, tooltips, theming)

---

## ADR-007: Race Condition Prevention com fetchId

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: Usuário pode trocar de zona rapidamente. Resposta antiga pode sobrescrever resposta nova.

**Decisão**: Usar contador incremental `_currentFetchId` em todos os providers assíncronos.

```dart
int _currentFetchId = 0;

Future<void> fetch() async {
  final fetchId = ++_currentFetchId;
  // ... await API call ...
  if (_currentFetchId == fetchId) {
    state = AsyncData(result);
  }
}
```

**Consequência**: Respostas obsoletas são descartadas automaticamente.

---

## ADR-008: Local-First Data Pattern (DataCenters + Countries)

**Status**: Atualizado  
**Data**: 2026-01-20

**Contexto**: Dados de referência (data centers Cloudflare, países) precisam estar disponíveis offline e carregar instantaneamente.

**Decisão**: Implementar padrão Local-First:
1. Carregar dados do asset local imediatamente (fallback)
2. Buscar versão atualizada do CDN em background
3. Atualizar state quando CDN responder

**Implementações**:

| Provider | Asset Local | CDN |
|----------|-------------|-----|
| `DataCentersNotifier` | `assets/data/cloudflare-iata-full.json` | GitHub raw |
| `CountryNotifier` | `assets/data/countries.json` | flagcdn.com/en/codes.json |

**Padrão de código**:
```dart
@override
FutureOr<Map<String, T>> build() async {
  final localData = await _loadFromAsset();
  if (!_hasFetched) {
    unawaited(_fetchFromCdn());
  }
  return localData;
}
```

**Consequência**: 
- App funciona offline
- UI carrega instantaneamente com dados locais
- Dados atualizados quando online (background refresh)

---

## ADR-009: Optimistic Updates para proxy toggle

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: Toggle de proxy (orange cloud) deve parecer instantâneo.

**Decisão**: 
1. Atualizar UI imediatamente
2. Fazer API call em background
3. Rollback se API falhar

**Consequência**: UX mais responsiva. Necessário tratamento de erro com rollback.

---

## ADR-010: DNSSEC Polling duplo

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: Cloudflare API pode demorar para refletir mudanças de DNSSEC.

**Decisão**: Após qualquer mudança, fazer polling duplo:
```dart
await updateDnssec(...);
await Future.delayed(Duration(seconds: 3));
await fetchSettings();
await Future.delayed(Duration(seconds: 2));
await fetchSettings();
```

**Consequência**: UI reflete estado real após ~5 segundos.

---

## ADR-011: Token validation (40+ caracteres)

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: API tokens Cloudflare têm pelo menos 40 caracteres.

**Decisão**: Validar token localmente antes de permitir acesso a rotas /dns/*.

**Consequência**: Feedback imediato para usuário. Evita calls desnecessárias à API.

---

## ADR-012: SfMaps com MapMarker em vez de MapBubbleLayer

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: MapBubbleSettings requer binding direto com shape data. Data centers não são países.

**Decisão**: Usar `markerBuilder` com `MapMarker` customizado para bubbles.

```dart
MapShapeLayer(
  source: MapShapeSource.asset('assets/data/world.json'),
  initialMarkersCount: dataPoints.length,
  markerBuilder: (context, index) => MapMarker(
    latitude: point.lat,
    longitude: point.lng,
    child: Container(...), // bubble circle
  ),
)
```

**Consequência**: Controle total sobre posição e tamanho dos bubbles.

---

## ADR-015: Makefile como gatekeeper (check + precommit)

**Status**: Atualizado
**Data**: 2025-12-31

**Contexto**: CI pode falhar por código não gerado ou análise não executada. Além disso, logs de comandos bem-sucedidos consomem tokens desnecessariamente.

**Decisão**: Usar Makefile com dois níveis de verificação:

1. `make check` - Validação rápida (~20s):
   - flutter pub get
   - dart run build_runner build
   - flutter analyze
   - flutter test

2. `make precommit` - Verificação completa (~30s):
   - Executa check
   - flutter build linux
   - flutter build apk

Todos os comandos suprimem logs de sucesso: `cmd > /tmp/log 2>&1 || cat /tmp/log`

**Consequência**:
- Feedback rápido durante desenvolvimento (`make check`)
- Garantia completa antes de commit (`make precommit`)
- Economia de tokens com supressão de logs
- `precommit.sh` mantido como fallback (deprecated)

---

## ADR-017: Zone auto-selection behaviors

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: Usuário pode ter muitas zonas. UX deve ser fluida.

**Decisão**:
| Situação | Comportamento |
|----------|---------------|
| Zona salva não existe mais | Selecionar primeira |
| Filtro retorna 1 resultado | Auto-selecionar |
| Nenhuma zona salva | Selecionar primeira |
| Troca de zona | Reset filtros |

**Consequência**: UX intuitiva. Menos cliques.

---

## ADR-018: Delete delay de 1200ms

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: Animação de delete (pulse vermelho) deve ser visível antes de item sumir.

**Decisão**: Delay de ~1200ms entre início de delete e execução da API call.

**Consequência**: Usuário vê feedback visual. Pode ser percebido como "lento" mas é intencional.

---

## ADR-019: GraphQL para Analytics

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: REST API não oferece analytics agregados. GraphQL permite queries flexíveis.

**Decisão**: Usar endpoint GraphQL (`/client/v4/graphql`) para analytics com query `dnsAnalyticsAdaptiveGroups`.

**Consequência**: Dados ricos. Query única para 7 dimensões.

---

## ADR-021: Sistema de Logging Híbrido (In-App + Arquivo)

**Status**: Aceito
**Data**: 2025-12-29

**Contexto**: Debug de problemas no app requer visibilidade de logs tanto em tempo real quanto histórico. No Android, acessar logcat é inconveniente. Compartilhar logs para análise precisa ser fácil.

**Decisão**: Implementar sistema de logging híbrido com:

1. **LogService Singleton**: Centraliza todos os logs com níveis (debug, info, api, warning, error)
2. **Aba Debug Logs**: Visualização em tempo real no Drawer
3. **Filtros por tempo**: 1m, 5m, 15m, 30m, All
4. **Filtros por categoria**: All, API, Errors, State, Debug
5. **Botão Copy**: Copia logs filtrados para clipboard
6. **Arquivo opcional**: Toggle nas Settings para persistir em arquivo

**Estrutura**:
```
lib/core/logging/
├── log_entry.dart          # Modelo de entrada
├── log_level.dart          # Níveis e categorias
├── log_service.dart        # Serviço singleton
├── log_provider.dart       # Providers Riverpod
└── presentation/
    └── debug_logs_page.dart
```

**Integração**:
- Interceptors Dio logam requests/responses automaticamente
- Providers logam state changes e erros
- main.dart captura FlutterError e async errors
- Global `log` helper para uso fácil: `log.error('msg', error: e)`

**Formato de Export**:
```
=== Debug Logs (last 5 min) ===
Session: 2025-12-29T19:00:00
Platform: android
Exported: 2025-12-29T19:05:00
Total entries: 42

[19:00:01.123] [API] GET /zones
  → 200 OK (145ms)
```

**Consequência**:
- Debug mais fácil em todas as plataformas
- Logs podem ser copiados e compartilhados para análise
- Arquivo opcional não impacta performance quando desativado

---

## ADR-022: Cache com Background Refresh (DNS Records e Zones)

**Status**: Atualizado
**Data**: 2025-12-31

**Contexto**: Ao acessar DNS Records ou lista de Zones, skeleton loading era exibido mesmo quando dados recentes estavam disponíveis. Isso causava uma experiência de "piscar" toda vez que o usuário acessava a tela.

**Decisão**: Implementar cache local com as seguintes características:

1. **Armazenamento**: SharedPreferences (JSON serializado)
2. **Chaves DNS**: `dns_records_cache_{zoneId}` e `dns_records_cache_time_{zoneId}`
3. **Chaves Zones**: `zones_cache` e `zones_cache_time`
4. **Expiração**: 3 dias
5. **Refresh**: Background (stale-while-revalidate)

**Fluxo**:
```
1. Ao acessar:
   - Tentar carregar cache
   - Se cache válido (<3 dias): mostrar imediatamente
   - Iniciar refresh em background

2. Durante refresh:
   - UI mostra isRefreshing=true (indicador sutil)
   - Se falhar: manter dados do cache
   - Se sucesso: atualizar lista

3. Cache atualizado em:
   - Fetch bem-sucedido
   - Create/Update/Delete de record
   - Toggle de proxy
```

**Campos em State**:
```dart
final bool isFromCache;
final bool isRefreshing;
final DateTime? cachedAt;
```

**Consequência**:
- UX muito melhorada: dados aparecem instantaneamente
- Funciona offline (enquanto cache válido)
- Background refresh garante dados atualizados
- 3 dias é conservador para DNS (TTLs típicos são menores)

---

## ADR-023: Analytics Pre-loading com Delay

**Status**: Aceito
**Data**: 2025-12-31

**Contexto**: Ao acessar aba Analytics pela primeira vez, exibia "No analytics data" em vez de loading. Além disso, fetch imediato em zona change bloqueava a UI da aba atual.

**Decisão**:
1. Iniciar com `isLoading: true` quando zona já selecionada
2. Delay de 500ms antes de fetch para não bloquear aba atual
3. Limpar dados anteriores ao trocar de zona (evitar dados stale)

```dart
// Ao trocar de zona
ref.listen(selectedZoneIdProvider, (prev, next) {
  state = const AnalyticsState(isLoading: true); // Reset
  _scheduleFetch(); // Delay 500ms
});

// Se já tem zona no build
if (currentZone != null) {
  _scheduleFetch();
  return const AnalyticsState(isLoading: true);
}
```

**Consequência**:
- Spinner exibido em vez de "No data"
- Aba Records/Settings carrega sem delay
- Analytics pronto quando usuário navega para aba

---

## Comandos Úteis

```bash
# Validação rápida durante desenvolvimento (~20s)
make check

# Verificação completa antes de commit (~30s)
make precommit

# Builds específicas
make android      # APK arm64 + upload via tdl
make android-x64  # APK x64 para emulador
make linux        # Linux release
make web          # Web release

# Desenvolvimento
make deps         # Instalar dependências
make gen          # Gerar código (Freezed, Retrofit)
make test         # Rodar testes
make analyze      # Análise estática
make clean        # Limpar artefatos

# Gerar ícones e splash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

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

## Problemas Conhecidos

1. **flutter_secure_storage_web usa dart:html**: Não compatível com WASM. Web build usa JavaScript renderer.

2. **Syncfusion Maps precisa de GeoJSON específico**: world.json deve ter propriedade `name` para cada país.

3. **CI precisa de build_runner**: Sempre adicionar step de code generation antes de analyze/build.

---

## ADR-024: Tab Preloading ao Mudar de Zona

**Status**: Aceito
**Data**: 2025-12-31

**Contexto**: Ao mudar de zona, apenas a aba ativa era carregada. Ao navegar para outras abas, o usuário via skeleton loading.

**Decisão**: Implementar preload inteligente das 3 abas DNS:

1. **Prioridade**: Aba ativa carrega primeiro
2. **Background**: Outras 2 abas carregam após delay de 300ms
3. **Paralelo**: Abas em background carregam simultaneamente

**Provider**: `TabPreloaderNotifier`
```dart
// Escuta mudança de zona
ref.listen(selectedZoneIdProvider, (prev, next) {
  if (next != null && prev != next) {
    _preloadAllTabs(next);
  }
});

// Preload com prioridade
void _preloadAllTabs(String zoneId) {
  _loadActiveTab();           // Imediato
  Future.delayed(300ms, () {
    _loadBackgroundTabs();    // Paralelo em bg
  });
}
```

**Integração**: `MainLayout` inicializa o preloader no build.

**Consequência**:
- Navegação entre abas é instantânea
- Aba ativa não é afetada pelo preload das outras
- Recursos de rede são melhor utilizados

---

## ADR-025: Sync de Data Centers na Build

**Status**: Aceito
**Data**: 2025-12-31

**Contexto**: Lista de data centers Cloudflare (IATA codes) precisa estar atualizada. Atualmente carrega de asset e atualiza do CDN em runtime.

**Decisão**: Adicionar sync na build para garantir dados mais recentes:

1. **Makefile target**: `sync-datacenters`
2. **Fonte**: GitHub raw (insign/Cloudflare-Data-Center-IATA-Code-list)
3. **Dependência**: `deps` depende de `sync-datacenters`

```makefile
sync-datacenters:
	@curl -fsSL $(IATA_URL) -o assets/data/cloudflare-iata-full.json

deps: sync-datacenters
	@flutter pub get
```

**Fluxo**:
```
make deps → sync-datacenters → pub get → código gerado
```

**Formato JSON** (já compatível):
```json
{
  "AMS": {"place": "Amsterdam, Netherlands", "lat": 52.3, "lng": 4.8, "cca2": "NL"},
  ...
}
```

**Consequência**:
- Dados sempre atualizados em cada build
- Nenhuma conversão necessária (formato compatível)
- CDN runtime continua como fallback

---

## ADR-026: Web Deploy via GitHub Actions (não Cloudflare Pages Build)

**Status**: Aceito
**Data**: 2026-01-20

**Contexto**: Cloudflare Pages não suporta Flutter nativamente. O build baixava o Flutter SDK (~1.4GB) a cada deploy, levando ~3 minutos. Tentativas de usar cache do CF Pages (via wrapper Eleventy) falharam - o cache era salvo mas não restaurado.

**Decisão**: Migrar build web para GitHub Actions com deploy via `wrangler pages deploy`:

1. **Build**: GitHub Actions com `subosito/flutter-action` (cache nativo funciona)
2. **Deploy**: `cloudflare/wrangler-action` faz upload direto para CF Pages
3. **CF Pages**: Hook de build pausado (apenas recebe uploads)

**Workflow** (`.github/workflows/build.yml`):
```yaml
build-web:
  needs: setup
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
      with:
        channel: 'stable'
        cache: true              # Cache do Flutter SDK
    - run: flutter pub get
    - run: flutter build web --release
    - uses: cloudflare/wrangler-action@v3
      with:
        apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
        accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
        command: pages deploy build/web --project-name=dash-for-cf
```

**Secrets necessários**:
- `CLOUDFLARE_ACCOUNT_ID`: ID da conta Cloudflare
- `CLOUDFLARE_API_TOKEN`: Token com permissão "Cloudflare Pages: Edit"

**Configuração CF Pages**:
- Settings → Builds & deployments → **Pause deployments**

**Resultado**:
| Métrica        | CF Pages Build | GitHub Actions |
| -------------- | -------------- | -------------- |
| Tempo (1º run) | ~3 min         | ~2 min         |
| Tempo (cached) | ~3 min (sem cache) | **~1m48s**     |
| Cache Flutter  | ❌ Não funciona | ✅ Funciona    |

**Consequência**:
- Builds mais rápidos com cache funcionando
- Controle total do pipeline via YAML
- Mesma URL de deploy: https://cf.dash.ad
- Requer manter secrets do Cloudflare no GitHub

---

_Última atualização: 2026-01-20 (atualizado ADR-008: Local-First Pattern para Countries)_
