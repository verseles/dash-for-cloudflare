# Testing Plan - Dash for Cloudflare

## Visão Geral

Este documento serve como roadmap para implementação de testes automatizados no projeto usando **Vitest** (testes unitários e de componentes) e **Playwright** (testes E2E).

---

## Instruções de Execução Autônoma

> **IMPORTANTE**: Ao executar este plano de forma autônoma:
> 1. Execute cada etapa sequencialmente
> 2. Ao concluir uma etapa com sucesso, faça commit das alterações
> 3. Só então prossiga para a próxima etapa
> 4. Se uma etapa falhar, corrija antes de avançar
> 5. Mantenha este arquivo atualizado marcando etapas concluídas com `[x]`

---

## Stack de Testes

| Ferramenta | Propósito | Versão Recomendada |
|------------|-----------|-------------------|
| Vitest | Testes unitários e de componentes | ^3.x |
| @vue/test-utils | Utilitários para montar componentes Vue | ^2.x |
| @vitest/coverage-v8 | Cobertura de código (rápido e preciso) | ^3.x |
| Playwright | Testes E2E | ^1.49.x |
| @quasar/quasar-app-extension-testing-unit-vitest | Integração Quasar + Vitest | latest |

---

## Roadmap de Implementação

### Fase 1: Configuração do Vitest

#### Etapa 1.1: Instalação de Dependências
- [ ] Instalar Vitest e dependências relacionadas
```bash
npm install -D vitest @vue/test-utils @vitest/coverage-v8 jsdom happy-dom
```

#### Etapa 1.2: Configuração do Vitest para Quasar
- [ ] Criar arquivo `vitest.config.ts` na raiz do projeto
```typescript
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'
import { quasar, transformAssetUrls } from '@quasar/vite-plugin'
import tsconfigPaths from 'vite-tsconfig-paths'

export default defineConfig({
  plugins: [
    vue({
      template: { transformAssetUrls }
    }),
    quasar({
      sassVariables: 'src/css/quasar.variables.scss'
    }),
    tsconfigPaths()
  ],
  test: {
    environment: 'happy-dom',
    globals: true,
    include: ['src/**/*.{test,spec}.{js,ts}', 'test/**/*.{test,spec}.{js,ts}'],
    exclude: ['node_modules', 'dist', 'e2e'],
    setupFiles: ['test/vitest/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      include: ['src/**/*.{ts,vue}'],
      exclude: [
        'src/**/*.d.ts',
        'src/**/*.{test,spec}.{ts,js}',
        'src/boot/**',
        'src/env.d.ts'
      ],
      reportsDirectory: 'coverage',
      thresholds: {
        statements: 60,
        branches: 60,
        functions: 60,
        lines: 60
      }
    }
  }
})
```

#### Etapa 1.3: Criar Setup File do Vitest
- [ ] Criar diretório `test/vitest/` e arquivo `setup.ts`
```typescript
// test/vitest/setup.ts
import { config } from '@vue/test-utils'
import { Quasar } from 'quasar'
import { vi } from 'vitest'

// Configuração global do Vue Test Utils com Quasar
config.global.plugins = [Quasar]

// Mock para APIs do navegador não disponíveis em happy-dom/jsdom
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
})

// Mock para ResizeObserver
global.ResizeObserver = vi.fn().mockImplementation(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
}))

// Mock para IntersectionObserver
global.IntersectionObserver = vi.fn().mockImplementation(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
}))
```

#### Etapa 1.4: Atualizar package.json
- [ ] Adicionar scripts de teste
```json
{
  "scripts": {
    "test": "vitest",
    "test:unit": "vitest run",
    "test:unit:watch": "vitest",
    "test:unit:coverage": "vitest run --coverage",
    "test:unit:ui": "vitest --ui"
  }
}
```

#### Etapa 1.5: Criar Helper para Montar Componentes Quasar
- [ ] Criar `test/vitest/helpers/mount-quasar.ts`
```typescript
import { mount, VueWrapper } from '@vue/test-utils'
import { Quasar } from 'quasar'
import { Component } from 'vue'
import { createPinia } from 'pinia'
import { createI18n } from 'vue-i18n'

interface MountQuasarOptions {
  props?: Record<string, unknown>
  slots?: Record<string, unknown>
  global?: Record<string, unknown>
  usePinia?: boolean
  useI18n?: boolean
}

export function mountQuasar(
  component: Component,
  options: MountQuasarOptions = {}
): VueWrapper {
  const plugins: unknown[] = [Quasar]

  if (options.usePinia !== false) {
    plugins.push(createPinia())
  }

  if (options.useI18n) {
    plugins.push(createI18n({
      legacy: false,
      locale: 'en-US',
      fallbackLocale: 'en-US',
      messages: {}
    }))
  }

  return mount(component, {
    props: options.props,
    slots: options.slots,
    global: {
      plugins,
      ...options.global
    }
  })
}
```

#### Etapa 1.6: Criar Primeiro Teste de Exemplo
- [ ] Criar `test/vitest/__tests__/example.spec.ts`
```typescript
import { describe, it, expect } from 'vitest'
import { mountQuasar } from '../helpers/mount-quasar'
import { QBtn } from 'quasar'

describe('Example Test Suite', () => {
  it('should mount a Quasar button', () => {
    const wrapper = mountQuasar(QBtn, {
      props: { label: 'Click me' }
    })

    expect(wrapper.text()).toContain('Click me')
  })

  it('should emit click event', async () => {
    const wrapper = mountQuasar(QBtn, {
      props: { label: 'Click me' }
    })

    await wrapper.trigger('click')
    expect(wrapper.emitted('click')).toBeTruthy()
  })
})
```

#### Etapa 1.7: Validar Configuração
- [ ] Executar `npm run test:unit` e garantir que os testes passam
- [ ] Executar `npm run test:unit:coverage` e verificar relatório

---

### Fase 2: Configuração do Playwright

#### Etapa 2.1: Instalação do Playwright
- [ ] Instalar Playwright
```bash
npm install -D @playwright/test
npx playwright install chromium firefox webkit
```

#### Etapa 2.2: Criar Configuração do Playwright
- [ ] Criar `playwright.config.ts` na raiz
```typescript
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  testMatch: '**/*.spec.ts',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { outputFolder: 'playwright-report' }],
    ['list']
  ],
  use: {
    baseURL: 'http://localhost:1222',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure'
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    // Mobile viewports
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'mobile-safari',
      use: { ...devices['iPhone 12'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:1222',
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },
})
```

#### Etapa 2.3: Criar Estrutura de Diretórios E2E
- [ ] Criar estrutura de pastas
```
e2e/
├── fixtures/
│   └── test-base.ts
├── pages/
│   └── BasePage.ts
├── utils/
│   └── helpers.ts
└── tests/
    └── example.spec.ts
```

#### Etapa 2.4: Criar Base Fixture
- [ ] Criar `e2e/fixtures/test-base.ts`
```typescript
import { test as base } from '@playwright/test'

// Extend base test com fixtures customizados
export const test = base.extend<{
  // Adicione fixtures customizados aqui conforme necessário
}>({
  // Exemplo de fixture customizado
  // authenticatedPage: async ({ page }, use) => {
  //   await page.goto('/login')
  //   await page.fill('[data-testid="email"]', 'user@example.com')
  //   await page.fill('[data-testid="password"]', 'password')
  //   await page.click('[data-testid="submit"]')
  //   await use(page)
  // }
})

export { expect } from '@playwright/test'
```

#### Etapa 2.5: Criar Page Object Base
- [ ] Criar `e2e/pages/BasePage.ts`
```typescript
import { Page, Locator } from '@playwright/test'

export abstract class BasePage {
  readonly page: Page

  constructor(page: Page) {
    this.page = page
  }

  async navigate(path: string = '/'): Promise<void> {
    await this.page.goto(path)
  }

  async waitForPageLoad(): Promise<void> {
    await this.page.waitForLoadState('networkidle')
  }

  getByTestId(testId: string): Locator {
    return this.page.locator(`[data-testid="${testId}"]`)
  }

  async takeScreenshot(name: string): Promise<void> {
    await this.page.screenshot({ path: `screenshots/${name}.png` })
  }
}
```

#### Etapa 2.6: Criar Teste E2E de Exemplo
- [ ] Criar `e2e/tests/example.spec.ts`
```typescript
import { test, expect } from '../fixtures/test-base'

test.describe('App Loading', () => {
  test('should load the application', async ({ page }) => {
    await page.goto('/')

    // Aguarda a aplicação carregar
    await page.waitForLoadState('networkidle')

    // Verifica se o título está presente
    await expect(page).toHaveTitle(/Dash for Cloudflare/i)
  })

  test('should display main content', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    // Adicione verificações específicas da sua aplicação
    // await expect(page.locator('[data-testid="main-content"]')).toBeVisible()
  })
})
```

#### Etapa 2.7: Atualizar package.json com Scripts E2E
- [ ] Adicionar scripts do Playwright
```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:debug": "playwright test --debug",
    "test:e2e:chromium": "playwright test --project=chromium",
    "test:e2e:report": "playwright show-report"
  }
}
```

#### Etapa 2.8: Validar Configuração E2E
- [ ] Executar `npm run test:e2e:chromium` e garantir que passa

---

### Fase 3: Testes Unitários de Componentes

#### Etapa 3.1: Identificar Componentes Críticos
- [ ] Listar componentes em `src/components/` que precisam de testes
- [ ] Priorizar por complexidade e importância

#### Etapa 3.2: Criar Testes para Componentes Básicos
- [ ] Criar testes para cada componente identificado seguindo padrão:
```typescript
// src/components/MyComponent.spec.ts
import { describe, it, expect, vi } from 'vitest'
import { mountQuasar } from '../../test/vitest/helpers/mount-quasar'
import MyComponent from './MyComponent.vue'

describe('MyComponent', () => {
  it('renders correctly', () => {
    const wrapper = mountQuasar(MyComponent)
    expect(wrapper.exists()).toBe(true)
  })

  it('handles props correctly', () => {
    const wrapper = mountQuasar(MyComponent, {
      props: { someProp: 'value' }
    })
    expect(wrapper.text()).toContain('value')
  })

  it('emits events correctly', async () => {
    const wrapper = mountQuasar(MyComponent)
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted('myEvent')).toBeTruthy()
  })
})
```

#### Etapa 3.3: Criar Testes para Composables
- [ ] Testar composables em `src/composables/` (se existir)
```typescript
import { describe, it, expect } from 'vitest'
import { useMyComposable } from './useMyComposable'

describe('useMyComposable', () => {
  it('returns expected values', () => {
    const { value, setValue } = useMyComposable()
    expect(value.value).toBe(initialValue)

    setValue('new value')
    expect(value.value).toBe('new value')
  })
})
```

---

### Fase 4: Testes de Stores (Pinia)

#### Etapa 4.1: Configurar Testes de Stores
- [ ] Criar helper para testar stores
```typescript
// test/vitest/helpers/test-store.ts
import { setActivePinia, createPinia } from 'pinia'
import { beforeEach } from 'vitest'

export function setupStoreTests() {
  beforeEach(() => {
    setActivePinia(createPinia())
  })
}
```

#### Etapa 4.2: Criar Testes para Cada Store
- [ ] Testar stores em `src/stores/`
```typescript
import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useMyStore } from './myStore'

describe('myStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('has correct initial state', () => {
    const store = useMyStore()
    expect(store.someValue).toBe(expectedInitial)
  })

  it('actions work correctly', async () => {
    const store = useMyStore()
    await store.fetchData()
    expect(store.data).toBeDefined()
  })
})
```

---

### Fase 5: Testes E2E Completos

#### Etapa 5.1: Criar Page Objects para Páginas Principais
- [ ] Criar Page Object para cada página principal
```typescript
// e2e/pages/HomePage.ts
import { BasePage } from './BasePage'
import { Page, Locator } from '@playwright/test'

export class HomePage extends BasePage {
  readonly loginButton: Locator
  readonly settingsButton: Locator

  constructor(page: Page) {
    super(page)
    this.loginButton = this.getByTestId('login-btn')
    this.settingsButton = this.getByTestId('settings-btn')
  }

  async clickLogin(): Promise<void> {
    await this.loginButton.click()
  }
}
```

#### Etapa 5.2: Criar Testes de Fluxos Principais
- [ ] Testar fluxos críticos do usuário
- [ ] Incluir testes de autenticação (se aplicável)
- [ ] Testar navegação entre páginas

#### Etapa 5.3: Adicionar Testes de Responsividade
- [ ] Testar em diferentes viewports usando projects do Playwright

---

### Fase 6: CI/CD Integration

#### Etapa 6.1: Criar GitHub Action para Testes
- [ ] Criar `.github/workflows/test.yml`
```yaml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run test:unit:coverage
      - uses: codecov/codecov-action@v4
        with:
          files: ./coverage/coverage-final.json

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npm run test:e2e
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

#### Etapa 6.2: Configurar Pre-commit Hooks (Opcional)
- [ ] Instalar husky e lint-staged
```bash
npm install -D husky lint-staged
npx husky init
```

- [ ] Configurar para rodar testes antes de commits

---

### Fase 7: Documentação e Manutenção

#### Etapa 7.1: Criar Guia de Contribuição para Testes
- [ ] Documentar padrões de teste
- [ ] Criar exemplos de testes bem escritos
- [ ] Documentar como executar testes localmente

#### Etapa 7.2: Configurar Thresholds de Cobertura
- [ ] Ajustar thresholds conforme cobertura aumenta
- [ ] Configurar CI para falhar se cobertura cair

---

## Estrutura Final de Diretórios

```
├── e2e/
│   ├── fixtures/
│   │   └── test-base.ts
│   ├── pages/
│   │   ├── BasePage.ts
│   │   └── [PageName]Page.ts
│   ├── tests/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   └── settings/
│   └── utils/
│       └── helpers.ts
├── test/
│   └── vitest/
│       ├── __tests__/
│       │   └── example.spec.ts
│       ├── helpers/
│       │   ├── mount-quasar.ts
│       │   └── test-store.ts
│       └── setup.ts
├── src/
│   ├── components/
│   │   ├── MyComponent.vue
│   │   └── MyComponent.spec.ts  # Testes co-localizados
│   └── stores/
│       ├── myStore.ts
│       └── myStore.spec.ts
├── vitest.config.ts
├── playwright.config.ts
└── package.json
```

---

## Boas Práticas

### Vitest / Testes Unitários

1. **Co-localização**: Mantenha testes próximos aos arquivos que testam (`Component.spec.ts` junto de `Component.vue`)
2. **Descrição clara**: Use `describe` e `it` com descrições que formem frases legíveis
3. **AAA Pattern**: Arrange (preparar), Act (agir), Assert (verificar)
4. **Mocks isolados**: Limpe mocks após cada teste com `vi.clearAllMocks()`
5. **Evite shallowMount**: Prefira `mount` para testes mais realistas
6. **Teste comportamento**: Foque em inputs/outputs, não em implementação interna

### Playwright / Testes E2E

1. **Page Object Model**: Abstraia interações com páginas em classes
2. **data-testid**: Use atributos `data-testid` para seletores robustos
3. **Evite timeouts fixos**: Use `waitFor*` em vez de `page.waitForTimeout()`
4. **Testes independentes**: Cada teste deve funcionar isoladamente
5. **Paralelização**: Escreva testes que possam rodar em paralelo
6. **Screenshots em falhas**: Configure para capturar evidências de erros

---

## Métricas de Sucesso

| Métrica | Meta Inicial | Meta Final |
|---------|--------------|------------|
| Cobertura de Statements | 60% | 80% |
| Cobertura de Branches | 60% | 75% |
| Cobertura de Functions | 60% | 80% |
| Cobertura de Lines | 60% | 80% |
| Testes E2E passando | 100% | 100% |
| Tempo de execução CI | < 10min | < 5min |

---

## Referências

- [Vue.js Testing Guide](https://vuejs.org/guide/scaling-up/testing)
- [Vitest Documentation](https://vitest.dev/)
- [Vue Test Utils](https://test-utils.vuejs.org/)
- [Playwright Documentation](https://playwright.dev/)
- [Quasar Testing](https://testing.quasar.dev/)
