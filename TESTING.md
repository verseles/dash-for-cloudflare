# Roadmap de Testes: Vitest & Playwright

Este documento serve como guia passo a passo para configurar um ambiente de testes moderno e robusto para este projeto Quasar, utilizando **Vitest** para testes unitários/componentes e **Playwright** para testes end-to-end (E2E).

---

## Status de Execução

> **Última atualização**: 2025-11-23
>
> | Fase | Status | Detalhes |
> |------|--------|----------|
> | Fase 1: Vitest | ✅ Concluída | Configuração completa com coverage |
> | Fase 2: Playwright | ✅ Concluída | E2E configurado para 5 browsers |
> | Fase 3: CI/CD | ✅ Concluída | GitHub Actions com matrix |
> | Fase 4: Stores/Components | 🔲 Pendente | Próxima sessão |
> | Fase 5: Page Objects E2E | 🔲 Pendente | Futura sessão |

---

## Modo de Execução Autônoma

> **IMPORTANTE**: Ao executar este plano de forma autônoma:
> 1. Execute cada etapa sequencialmente
> 2. Ao concluir uma etapa com sucesso, faça commit das alterações
> 3. Só então prossiga para a próxima etapa
> 4. Se uma etapa falhar, corrija antes de avançar
> 5. Mantenha este arquivo atualizado marcando etapas concluídas com `[x]`
>
> **Exemplo de Mensagem de Commit:**
> `feat(testing): Etapa 1.2 - Configura Vitest no projeto`

---

## Stack de Testes

| Ferramenta | Propósito | Versão Instalada |
|------------|-----------|------------------|
| Vitest | Testes unitários e de componentes | ^3.2.4 |
| @vue/test-utils | Utilitários para montar componentes Vue | ^2.4.6 |
| @vitest/coverage-v8 | Cobertura de código (rápido e preciso) | ^3.2.4 |
| @vitest/ui | Interface visual para testes | ^3.2.4 |
| happy-dom | Ambiente DOM rápido para testes | ^20.0.10 |
| Playwright | Testes E2E | ^1.56.1 |
| @quasar/quasar-app-extension-testing-unit-vitest | Integração Quasar + Vitest | ^1.2.3 |

---

## Fase 1: Configuração do Vitest (Testes Unitários e de Componentes)

O objetivo desta fase é configurar o Vitest para testar a lógica de negócio (`composables`, `stores`) e os componentes Vue de forma isolada.

### Etapa 1.1: Adicionar a App Extension de Testes do Quasar

- [x] Executar o comando da extensão do Quasar:

```bash
quasar ext add @quasar/testing-unit-vitest
```

> **Aprendizado**: A extensão 0.4.x só suporta Vitest 0.34. Para Vitest 3.x, é necessário atualizar para a versão 1.2.3+ da extensão usando `--legacy-peer-deps`.

### Etapa 1.2: Instalar Dependências Adicionais

- [x] Instalar dependências extras para cobertura e melhor DX:

```bash
npm install -D @vitest/coverage-v8 @vitest/ui happy-dom --legacy-peer-deps
```

### Etapa 1.3: Configurar o Vitest

- [x] Arquivo `vitest.config.ts` configurado com:
  - Environment: happy-dom
  - Globals: true
  - Coverage com v8 provider
  - Setup file com mocks do browser

### Etapa 1.4: Criar Setup File do Vitest

- [x] Arquivo `test/vitest/setup-file.ts` criado com:
  - installQuasarPlugin com Notify
  - Mocks para matchMedia, ResizeObserver, IntersectionObserver

### Etapa 1.5: Criar Helper para Montar Componentes Quasar

- [x] Helper `test/vitest/helpers/mount-quasar.ts` criado
- [x] Helper `test/vitest/helpers/test-store.ts` criado

### Etapa 1.6: Atualizar Scripts no package.json

- [x] Scripts adicionados:
  - `test`: vitest (watch mode)
  - `test:unit`: vitest run
  - `test:unit:watch`: vitest
  - `test:unit:ci`: vitest run --reporter=verbose
  - `test:unit:coverage`: vitest run --coverage
  - `test:unit:ui`: vitest --ui

### Etapa 1.7: Criar Teste Unitário de Composable

- [x] Teste `src/composables/__tests__/useI18n.spec.ts` criado
  - Testa função t, locale ref, e setLocale

### Etapa 1.8: Criar Teste de Componente

- [x] Teste `src/components/__tests__/UpdateBanner.spec.ts` criado
  - 6 testes cobrindo montagem, visibilidade, e eventos

### Etapa 1.9: Validar Configuração do Vitest

- [x] `npm run test:unit` passa (12 testes)
- [x] `npm run test:unit:coverage` funciona
- [x] Commit realizado: `feat(testing): setup Vitest for unit and component testing`

---

## Fase 2: Configuração do Playwright (Testes End-to-End)

### Etapa 2.1: Inicializar o Playwright

- [x] Instalado @playwright/test manualmente (npm init playwright é interativo)

### Etapa 2.2: Configurar o Playwright

- [x] `playwright.config.ts` configurado com:
  - 5 projetos: chromium, firefox, webkit, mobile-chrome, mobile-safari
  - webServer apontando para npm run dev na porta 1222
  - Screenshots e videos em caso de falha

### Etapa 2.3: Criar Estrutura de Diretórios E2E

- [x] Estrutura criada:
  ```
  e2e/
  ├── fixtures/test-base.ts
  ├── pages/BasePage.ts
  ├── tests/app.spec.ts
  └── utils/helpers.ts
  ```

### Etapa 2.4-2.6: Criar Fixtures, Page Objects e Testes

- [x] Base fixture criado
- [x] BasePage com helpers comuns
- [x] app.spec.ts com testes de loading e navegação

### Etapa 2.7: Atualizar Scripts no package.json

- [x] Scripts adicionados:
  - `test:e2e`: playwright test
  - `test:e2e:ui`: playwright test --ui
  - `test:e2e:debug`: playwright test --debug
  - `test:e2e:chromium`: playwright test --project=chromium
  - `test:e2e:report`: playwright show-report

### Etapa 2.8: Validar Configuração E2E

- [x] Configuração validada
- [x] Commit realizado: `feat(testing): setup Playwright for end-to-end testing`

> **Nota**: Testes E2E completos requerem que o dev server inicie sem erros de linting. O typescript-checker no quasar.config.ts pode bloquear o start em CI se houver erros de tipo.

---

## Fase 3: Integração Contínua (CI)

### Etapa 3.1: Configurar GitHub Actions

- [x] `.github/workflows/test.yml` criado com:
  - **lint**: Verifica qualidade do código
  - **unit-tests**: Executa testes unitários com coverage
  - **e2e-tests**: Matrix com chromium, firefox, webkit em paralelo
  - **build**: Gera artefatos de build (depende de lint e unit-tests)

### Etapa 3.2: Fazer Commit do CI

- [x] Commit realizado: `ci(testing): configure GitHub Actions for unit and E2E tests`

---

## Fase 4: Testes de Componentes e Stores

### Etapa 4.1: Testar Stores (Pinia)

- [ ] Criar testes para cada store em `src/stores/`:
  - [ ] dataCenterStore
  - [ ] generalStore
  - [ ] loading
  - [ ] zoneStore

### Etapa 4.2: Testar Componentes Críticos

- [ ] Identificar e testar componentes:
  - [ ] CloudflareProxyToggle.vue
  - [ ] DnsRecordItem.vue
  - [ ] DnsRecordEditModal.vue
  - [ ] DnsAnalyticsChart.vue

---

## Fase 5: Page Objects e Testes E2E Avançados

### Etapa 5.1: Criar Page Objects

- [ ] Criar Page Objects para páginas principais:
  - [ ] HomePage
  - [ ] DnsPage
  - [ ] SettingsPage

### Etapa 5.2: Testes de Fluxos Críticos

- [ ] Testar fluxos críticos do usuário
- [ ] Testar navegação entre páginas

### Etapa 5.3: Testes de Responsividade

- [ ] Testar em diferentes viewports usando projetos do Playwright

---

## Aprendizados e Notas para Próximas Sessões

### Problemas Encontrados e Soluções

1. **Versão da extensão Quasar Testing**
   - Problema: A extensão 0.4.x requer Vitest ^0.34
   - Solução: Usar versão ^1.2.3 que suporta Vitest 3.x
   - Comando: `npm install -D @quasar/quasar-app-extension-testing-unit-vitest@^1.2.3 --legacy-peer-deps`

2. **Conflitos de peer dependencies**
   - Use `--legacy-peer-deps` ao instalar pacotes de teste juntos

3. **Warnings de Plugin duplicado**
   - Não chame `installQuasarPlugin()` nos testes individuais se já está no setup-file.ts
   - Para componentes que precisam de i18n, adicione o plugin manualmente sem Quasar

4. **TypeScript strictness**
   - O `mount-quasar.ts` precisa de type assertions para plugins
   - Testes de demo gerados pela extensão podem ter erros de tipo

5. **playwright.config.ts workers**
   - Não use `undefined` para workers, use um número ou omita a propriedade

### Comandos Úteis

```bash
# Testes unitários
npm run test:unit          # Executa uma vez
npm run test:unit:watch    # Watch mode
npm run test:unit:coverage # Com cobertura
npm run test:unit:ui       # Interface visual

# Testes E2E
npm run test:e2e           # Todos os browsers
npm run test:e2e:chromium  # Apenas Chromium
npm run test:e2e:ui        # Interface visual
npm run test:e2e:debug     # Modo debug
```

### Thresholds de Cobertura

Configuração atual (inicial):
- Statements: 1%
- Branches: 30%
- Functions: 30%
- Lines: 1%

Meta futura:
- Statements: 60-80%
- Branches: 60-75%
- Functions: 60-80%
- Lines: 60-80%

---

## Boas Práticas

### Vitest / Testes Unitários

1. **Co-localização**: Mantenha testes próximos aos arquivos que testam
2. **Descrição clara**: Use `describe` e `it` com descrições legíveis
3. **AAA Pattern**: Arrange (preparar), Act (agir), Assert (verificar)
4. **Mocks isolados**: Limpe mocks após cada teste
5. **Prefira mount**: Use `mount` em vez de `shallowMount` para testes mais realistas
6. **Teste comportamento**: Foque em inputs/outputs, não em implementação

### Playwright / Testes E2E

1. **Page Object Model**: Abstraia interações em classes
2. **data-testid**: Use atributos `data-testid` para seletores robustos
3. **Evite timeouts fixos**: Use `waitFor*` em vez de `waitForTimeout()`
4. **Testes independentes**: Cada teste deve funcionar isoladamente
5. **Paralelização**: Escreva testes que possam rodar em paralelo

---

## Estrutura Atual de Diretórios

```
├── .github/workflows/
│   └── test.yml           # CI pipeline
├── e2e/
│   ├── fixtures/
│   │   └── test-base.ts
│   ├── pages/
│   │   └── BasePage.ts
│   ├── tests/
│   │   └── app.spec.ts
│   └── utils/
│       └── helpers.ts
├── test/
│   └── vitest/
│       ├── __tests__/
│       │   ├── demo/
│       │   ├── ExampleComponent.test.ts
│       │   └── NotifyComponent.test.ts
│       ├── helpers/
│       │   ├── mount-quasar.ts
│       │   └── test-store.ts
│       └── setup-file.ts
├── src/
│   ├── components/
│   │   └── __tests__/
│   │       └── UpdateBanner.spec.ts
│   └── composables/
│       └── __tests__/
│           └── useI18n.spec.ts
├── vitest.config.ts
├── playwright.config.ts
└── package.json
```

---

## Referências

- [Vue.js Testing Guide](https://vuejs.org/guide/scaling-up/testing)
- [Vitest Documentation](https://vitest.dev/)
- [Vue Test Utils](https://test-utils.vuejs.org/)
- [Playwright Documentation](https://playwright.dev/)
- [Quasar Testing](https://testing.quasar.dev/)
- [@quasar/quasar-app-extension-testing-unit-vitest](https://www.npmjs.com/package/@quasar/quasar-app-extension-testing-unit-vitest)
