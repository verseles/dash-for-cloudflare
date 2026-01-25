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

## ADR-022: Cache com Background Refresh (Padrão SWR)

**Status**: Atualizado
**Data**: 2026-01-23

**Contexto**: O tempo de carregamento da API da Cloudflare pode variar. Exibir skeleton loadings em cada navegação prejudica a fluidez.

**Decisão**: Implementar o padrão **Stale-While-Revalidate (SWR)** em todos os módulos principais (DNS, Workers, Pages):

1. **Armazenamento**: SharedPreferences (JSON serializado)
2. **Expiração**: 3 dias
3. **Refresh**: Background (automático ao acessar a tela)
4. **Abrangência**:
   - **DNS**: Zones, Records e Settings.
   - **Workers**: Scripts list, Settings, Schedules, Domains e Routes.
   - **Pages**: Projects list, Deployments e Custom Domains.

**Fluxo**:
```
1. Ao acessar:
   - Tentar carregar cache local
   - Se cache existe: mostrar imediatamente (isFromCache: true)
   - Iniciar refresh em background (isRefreshing: true)

2. Durante refresh:
   - UI mostra indicador sutil (LinearProgress ou skipLoadingOnRefresh)
   - Se falhar: manter dados do cache
   - Se sucesso: atualizar estado e persistir novo cache
```

**Consequência**:
- UX instantânea: dados aparecem sem spinners centrais
- App funciona offline com dados em cache
- Consistência arquitetural entre funcionalidades

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

## ADR-024: Tab Preloading em Segundo Plano

**Status**: Atualizado
**Data**: 2026-01-23

**Contexto**: Ao abrir uma zona (DNS) ou um Worker, o usuário inicia na aba principal. Navegar para outras abas causava skeleton loading mesmo com cache SWR, devido ao delay inicial da API.

**Decisão**: Implementar preload inteligente das abas secundárias em segundo plano:

1. **Gatilho**: Mudança de zona selecionada ou abertura de detalhes de um Worker.
2. **Prioridade**: Aba ativa carrega imediatamente.
3. **Background**: Abas secundárias carregam após delay de 300-800ms.
4. **Abrangência**:
   - **DNS**: Records, Analytics e Settings.
   - **Workers**: Overview, Triggers e Settings.

**Implementação**:
- `TabPreloaderNotifier` (DNS)
- `WorkerTabPreloader` (Workers)

**Consequência**:
- Navegação entre abas torna-se instantânea
- Redução drástica na percepção de latência da rede
- Melhor aproveitamento do ciclo de vida dos providers Riverpod

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

## ADR-027: Auto-Polling para Estados Transitórios (Pages)

**Status**: Aceito
**Data**: 2026-01-22

**Contexto**: Deployments de Pages passam por estados transitórios (queued, building). Usuário precisa ver atualização sem refresh manual.

**Decisão**: Implementar polling condicional que:
1. Inicia automaticamente quando há items em estado ativo (building/queued)
2. Para automaticamente quando todos items completam
3. Usa Timer com intervalo de 5 segundos (balance entre responsividade e rate limit)

**Implementação**:
```dart
class _PageState extends ConsumerState<Page> {
  Timer? _pollingTimer;
  static const _pollingInterval = Duration(seconds: 5);

  void _updatePolling(List<Item> items) {
    final hasActive = items.any((i) => i.isBuilding);
    
    if (hasActive && _pollingTimer == null) {
      _pollingTimer = Timer.periodic(_pollingInterval, (_) {
        ref.read(provider.notifier).refresh();
      });
    } else if (!hasActive && _pollingTimer != null) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
```

**Aplicações**:
- `PagesListPage`: Polling quando projeto tem deploy ativo
- `PagesProjectPage`: Polling quando deployment está building/queued
- `DeploymentLogsNotifier`: Polling de logs a cada 3s durante build

**Consequência**:
- UX responsiva sem refresh manual
- Timer cleanup no dispose evita memory leaks
- Polling para automaticamente (não desperdiça recursos)
- Rate limit respeitado (5s é conservador)

---

## ADR-028: Migração para Material Symbols

**Status**: Aceito
**Data**: 2026-01-23

**Contexto**: O conjunto de ícones padrão `Material Icons` é limitado em termos de personalização visual (weight, fill, grade). Para um visual mais moderno e alinhado com o Material 3 avançado, era necessária uma biblioteca mais flexível.

**Decisão**: Substituir todos os ícones pela biblioteca `material_symbols_icons`.

**Padrões estabelecidos**:
1. Usar a classe `Symbols` em vez de `Icons`.
2. Para Bottom Navigation e abas, usar `fill: 0` para o estado inativo e `fill: 1` para o estado selecionado.
3. Ícones principais definidos:
   - DNS: `graph_3`
   - Analytics: `finance_mode`
   - Pages: `electric_bolt`
   - Settings: `settings`

**Consequência**: Consistência visual aprimorada e maior controle sobre a expressividade dos ícones sem aumentar o tamanho do bundle significativamente.

---

## ADR-029: Persistência da Última Rota Visitada

**Status**: Aceito
**Data**: 2026-01-23

**Contexto**: Usuários que alternam entre DNS, Analytics e Pages frequentemente perdiam o contexto ao fechar o app, sempre retornando para a tela inicial (DNS).

**Decisão**: Implementar persistência automática da última rota visitada.

**Implementação**:
1. Adicionado campo `lastVisitedRoute` ao modelo `AppSettings`.
2. `AppRouter` utiliza um listener no `GoRouter` para disparar atualizações de configuração sempre que a rota muda.
3. Na inicialização, o `initialLocation` do router é extraído das configurações salvas.

**Consequência**: Melhoria significativa na UX e continuidade do fluxo de trabalho do usuário.

---

## ADR-030: Estratégia de Testes (Test Pyramid)

**Status**: Aceito
**Data**: 2026-01-25

**Contexto**: Com o crescimento da base de código, testes manuais tornaram-se inviáveis e propensos a erro. Era necessário definir uma estratégia clara para garantir a qualidade do código em diferentes níveis.

**Decisão**: Adotar a estratégia da **Pirâmide de Testes**, dividindo os testes em três camadas com responsabilidades distintas:

1.  **Unit Tests (`test/unit/`)**:
    *   **Foco**: Lógica de negócios pura, parsers, models (Freezed), e transformações de dados.
    *   **Ferramentas**: `flutter_test`, `mockito`.
    *   **Volume**: Maior quantidade, execução rápida (<10ms).
    *   **Dependências**: Mockadas completamente.

2.  **Widget Tests (`test/widget/`)**:
    *   **Foco**: Componentes de UI isolados, interações simples (taps, inputs), e renderização condicional.
    *   **Ferramentas**: `widget_test`, `pumpWidget`.
    *   **Volume**: Quantidade média.
    *   **Dependências**: Providers Riverpod sobrescritos com mocks ou dados estáticos.

3.  **Integration Tests (`test/integration/`)**:
    *   **Foco**: Fluxos completos do usuário (ex: adicionar registro DNS, rollback de deployment).
    *   **Ferramentas**: `integration_test` (simulado via `widget_test` com `Robot Pattern`).
    *   **Volume**: Menor quantidade, execução mais lenta.
    *   **Dependências**: Simula o app inteiro, mas com mocks na camada de rede (Dio/Retrofit) para determinismo.

**Consequência**:
*   Maior confiança em refatorações.
*   Documentação viva do comportamento do sistema.
*   Execução rápida no CI (`make check`).

---

## ADR-031: Padrão de Auto-save (Blur vs Immediate)

**Status**: Aceito
**Data**: 2026-01-25

**Contexto**: Aplicações modernas tendem a remover botões de "Salvar" explícitos para reduzir fricção. No entanto, salvar a cada keystroke pode causar excesso de requisições e validações prematuras.

**Decisão**: Implementar um padrão híbrido de auto-save dependendo do tipo de input:

1.  **Inputs de Texto (TextField/TextFormField)**:
    *   **Gatilho**: `onBlur` (perda de foco) ou `onEditingComplete` (Enter).
    *   **Justificativa**: Evita requisições incompletas enquanto o usuário digita.

2.  **Toggles e Seletores (Switch/Dropdown)**:
    *   **Gatilho**: `onChange` (Imediato).
    *   **Justificativa**: A intenção do usuário é clara e a mudança é binária/atômica.

3.  **Feedback Visual**:
    *   Exibir indicadores sutis de carregamento ou notificações (Toasts) em caso de erro.
    *   Manter o estado local otimista quando possível (ver ADR-009).

**Consequência**:
*   UX mais fluida e moderna.
*   Redução de cliques desnecessários.
*   Necessidade de tratamento de erros robusto para reverter estados otimistas em caso de falha.

---

_Última atualização: 2026-01-25 (adicionado ADR-030 e ADR-031)_