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

## ADR-002: Código gerado NÃO commitado

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: Arquivos `.g.dart` e `.freezed.dart` são gerados por build_runner.

**Decisão**: 
- Não commitar arquivos gerados (estão no .gitignore)
- CI deve rodar `dart run build_runner build --delete-conflicting-outputs` antes de analyze/build
- Desenvolvedor local deve rodar `./precommit.sh` antes de push

**Consequência**: Repositório mais limpo, mas CI e local devem regenerar código.

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

## ADR-004: flutter_secure_storage apenas para API Token

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: flutter_secure_storage usa Keychain (iOS), Keystore (Android), libsecret (Linux). É mais seguro mas mais lento.

**Decisão**:
- API Token → flutter_secure_storage (dados sensíveis)
- Tema, idioma, zona selecionada → shared_preferences (dados não-sensíveis)

**Consequência**: Performance melhor para preferências, segurança para credenciais.

---

## ADR-005: Freezed 3.x com sealed classes

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: Freezed 3.x introduziu suporte a `sealed class` do Dart 3 para melhor pattern matching.

**Decisão**: Usar sintaxe `sealed class` em todos os models Freezed.

```dart
@freezed
sealed class Zone with _$Zone {
  const factory Zone({...}) = _Zone;
}
```

**Consequência**: Melhor suporte a pattern matching, exhaustiveness checking do compilador.

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

## ADR-008: DataCentersProvider com fallback local

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: Dados de data centers Cloudflare (IATA codes → lat/lng) precisam estar disponíveis offline.

**Decisão**:
1. Carregar `assets/data/cloudflare-iata-full.json` imediatamente (fallback)
2. Buscar versão atualizada do CDN em background
3. Suportar ambos formatos JSON (object e array)

**Consequência**: App funciona offline. Dados atualizados quando online.

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

## ADR-013: Estrutura feature-based

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: Projeto tem múltiplos domínios (auth, dns, analytics).

**Decisão**: Estrutura de pastas feature-based:
```
lib/
├── core/           # Shared code
│   ├── api/
│   ├── providers/
│   ├── theme/
│   └── widgets/
├── features/
│   ├── auth/       # Settings, token
│   ├── dns/        # Records, settings
│   └── analytics/  # Charts, data
└── l10n/           # Translations
```

**Consequência**: Código organizado por domínio. Fácil navegação.

---

## ADR-014: StatefulShellRoute para DNS tabs

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: Tabs DNS (Records, Analytics, Settings) devem preservar estado ao alternar.

**Decisão**: Usar `StatefulShellRoute` do go_router.

**Consequência**: Estado preservado entre tabs. Melhor UX.

---

## ADR-015: precommit.sh como gatekeeper

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: CI pode falhar por código não gerado ou análise não executada.

**Decisão**: Criar `precommit.sh` que executa:
1. flutter pub get
2. dart run build_runner build
3. flutter analyze
4. flutter test
5. flutter build linux (opcional)

**Consequência**: Desenvolvedor verifica localmente antes de push. Menos CI failures.

---

## ADR-016: Cloudflare orange (#F38020) como primary color

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: App deve ter identidade visual alinhada com Cloudflare.

**Decisão**: Usar `#F38020` como primary color no tema.

**Consequência**: Consistência visual. Splash screen e ícones usam mesma cor.

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

## ADR-020: Internacionalização com ARB files

**Status**: Aceito  
**Data**: 2025-12-29

**Contexto**: App deve suportar múltiplos idiomas.

**Decisão**: Usar flutter_localizations + intl com arquivos ARB.

```
lib/l10n/
├── app_en.arb  # English (default)
└── app_pt.arb  # Portuguese
```

**Consequência**: Suporte oficial Flutter. Fácil adicionar idiomas.

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

## Comandos Úteis

```bash
# Gerar código (Freezed, Retrofit, Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Gerar ícones
dart run flutter_launcher_icons

# Gerar splash screen
dart run flutter_native_splash:create

# Rodar testes
flutter test

# Build release
flutter build linux --release
flutter build web --release
flutter build apk --release

# Verificação completa antes de commit
./precommit.sh
```

---

## Problemas Conhecidos

1. **flutter_secure_storage_web usa dart:html**: Não compatível com WASM. Web build usa JavaScript renderer.

2. **Syncfusion Maps precisa de GeoJSON específico**: world.json deve ter propriedade `name` para cada país.

3. **CI precisa de build_runner**: Sempre adicionar step de code generation antes de analyze/build.

---

_Última atualização: 2025-12-29 (ADR-021 adicionado)_
