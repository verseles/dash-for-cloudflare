# Roadmap de Testes: Vitest & Playwright

Este documento serve como guia passo a passo para configurar um ambiente de testes moderno e robusto para este projeto Quasar, utilizando **Vitest** para testes unitários/componentes e **Playwright** para testes end-to-end (E2E).

---

## Modo de Execucao Autonoma

> **IMPORTANTE**: Ao executar este plano de forma autonoma:
> 1. Execute cada etapa sequencialmente
> 2. Ao concluir uma etapa com sucesso, faca commit das alteracoes
> 3. So entao prossiga para a proxima etapa
> 4. Se uma etapa falhar, corrija antes de avancar
> 5. Mantenha este arquivo atualizado marcando etapas concluidas com `[x]`
>
> **Exemplo de Mensagem de Commit:**
> `feat(testing): Etapa 1.2 - Configura Vitest no projeto`

---

## Stack de Testes

| Ferramenta | Proposito | Versao Recomendada |
|------------|-----------|-------------------|
| Vitest | Testes unitarios e de componentes | ^3.x |
| @vue/test-utils | Utilitarios para montar componentes Vue | ^2.x |
| @vitest/coverage-v8 | Cobertura de codigo (rapido e preciso) | ^3.x |
| Playwright | Testes E2E | ^1.49.x |
| @quasar/quasar-app-extension-testing-unit-vitest | Integracao Quasar + Vitest | latest |

---

## Fase 1: Configuracao do Vitest (Testes Unitarios e de Componentes)

O objetivo desta fase e configurar o Vitest para testar a logica de negocio (`composables`, `stores`) e os componentes Vue de forma isolada.

### Etapa 1.1: Adicionar a App Extension de Testes do Quasar

- [ ] Executar o comando da extensao do Quasar:

```bash
quasar ext add @quasar/testing-unit-vitest
```

Este comando ira:
1. Instalar o `vitest`, `@vue/test-utils` e outras dependencias necessarias
2. Criar um arquivo de configuracao `vitest.config.ts`
3. Adicionar os scripts de teste (`"test:unit"`, `"test:unit:ci"`) ao seu `package.json`

### Etapa 1.2: Instalar Dependencias Adicionais

- [ ] Instalar dependencias extras para cobertura e melhor DX:

```bash
npm install -D @vitest/coverage-v8 @vitest/ui happy-dom
```

### Etapa 1.3: Configurar o Vitest

- [ ] Verificar/ajustar o arquivo `vitest.config.ts` criado pela extensao:

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

### Etapa 1.4: Criar Setup File do Vitest

- [ ] Criar diretorio `test/vitest/` e arquivo `setup.ts`:

```typescript
// test/vitest/setup.ts
import { config } from '@vue/test-utils'
import { Quasar } from 'quasar'
import { vi } from 'vitest'
import { installQuasarPlugin } from '@quasar/quasar-app-extension-testing-unit-vitest'

// Instala o plugin do Quasar para os testes
installQuasarPlugin()

// Mock para APIs do navegador nao disponiveis em happy-dom/jsdom
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

### Etapa 1.5: Criar Helper para Montar Componentes Quasar

- [ ] Criar `test/vitest/helpers/mount-quasar.ts`:

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

### Etapa 1.6: Atualizar Scripts no package.json

- [ ] Verificar/adicionar scripts de teste:

```json
{
  "scripts": {
    "test": "vitest",
    "test:unit": "vitest run",
    "test:unit:watch": "vitest",
    "test:unit:ci": "vitest run --reporter=verbose",
    "test:unit:coverage": "vitest run --coverage",
    "test:unit:ui": "vitest --ui"
  }
}
```

### Etapa 1.7: Criar Teste Unitario de Composable

- [ ] Criar `src/composables/__tests__/useI18n.spec.ts`:

```typescript
import { describe, it, expect } from 'vitest'
import { useI18n } from '../useI18n'

describe('useI18n', () => {
  it('should return a t function', () => {
    const { t } = useI18n()
    expect(typeof t).toBe('function')
  })

  it('should translate a known key', () => {
    const { t } = useI18n('settings')
    const translatedString = t('language')
    expect(translatedString).toBeTypeOf('string')
  })
})
```

### Etapa 1.8: Criar Teste de Componente

- [ ] Criar `src/components/__tests__/UpdateBanner.spec.ts`:

```typescript
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { installQuasarPlugin } from '@quasar/quasar-app-extension-testing-unit-vitest'
import UpdateBanner from '../UpdateBanner.vue'

installQuasarPlugin()

describe('UpdateBanner', () => {
  it('monta o componente corretamente', () => {
    const wrapper = mount(UpdateBanner)
    expect(wrapper.exists()).toBe(true)
  })

  it('exibe a mensagem de atualizacao', () => {
    const wrapper = mount(UpdateBanner)
    const banner = wrapper.find('.q-banner')
    expect(banner.text()).toContain('New version available')
  })
})
```

### Etapa 1.9: Validar Configuracao do Vitest

- [ ] Executar `npm run test:unit` e garantir que os testes passam
- [ ] Executar `npm run test:unit:coverage` e verificar relatorio
- [ ] Fazer commit:

```bash
git add .
git commit -m "feat(testing): setup vitest for unit and component testing"
```

---

## Fase 2: Configuracao do Playwright (Testes End-to-End)

O objetivo e configurar o Playwright para rodar testes que simulam a interacao real do usuario com a aplicacao em um navegador real.

### Etapa 2.1: Inicializar o Playwright

- [ ] Rodar o comando de inicializacao:

```bash
npm init playwright@latest
```

Responda as perguntas:
- Where to put your end-to-end tests? -> `e2e`
- Add a GitHub Actions workflow? -> `Yes`
- Install Playwright browsers? -> `Yes`

### Etapa 2.2: Configurar o Playwright

- [ ] Editar `playwright.config.ts`:

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

### Etapa 2.3: Criar Estrutura de Diretorios E2E

- [ ] Criar estrutura de pastas:

```
e2e/
├── fixtures/
│   └── test-base.ts
├── pages/
│   └── BasePage.ts
├── utils/
│   └── helpers.ts
└── tests/
    └── app.spec.ts
```

### Etapa 2.4: Criar Base Fixture

- [ ] Criar `e2e/fixtures/test-base.ts`:

```typescript
import { test as base } from '@playwright/test'

export const test = base.extend<{
  // Adicione fixtures customizados aqui conforme necessario
}>({
  // Exemplo de fixture customizado para autenticacao:
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

### Etapa 2.5: Criar Page Object Base

- [ ] Criar `e2e/pages/BasePage.ts`:

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

### Etapa 2.6: Criar Teste E2E

- [ ] Criar `e2e/tests/app.spec.ts`:

```typescript
import { test, expect } from '@playwright/test'

test.describe('App Loading', () => {
  test('should load the application', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')
    await expect(page).toHaveTitle(/Dash for Cloudflare/i)
  })

  test('has dns page link', async ({ page }) => {
    await page.goto('/')

    const dnsLink = page.getByRole('link', { name: 'DNS' })
    await expect(dnsLink).toBeVisible()
    await dnsLink.click()

    await expect(page).toHaveURL(/.*\/dns/)
  })
})
```

### Etapa 2.7: Atualizar Scripts no package.json

- [ ] Adicionar scripts do Playwright:

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

### Etapa 2.8: Validar Configuracao E2E

- [ ] Executar `npm run test:e2e:chromium` e garantir que passa
- [ ] Fazer commit:

```bash
git add .
git commit -m "feat(testing): setup playwright for end-to-end testing"
```

---

## Fase 3: Integracao Continua (CI)

### Etapa 3.1: Configurar GitHub Actions

- [ ] Criar/editar `.github/workflows/test.yml`:

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

### Etapa 3.2: Fazer Commit do CI

- [ ] Fazer commit:

```bash
git add .
git commit -m "ci(testing): configure github actions to run unit and e2e tests"
```

---

## Fase 4: Testes de Componentes e Stores

### Etapa 4.1: Testar Stores (Pinia)

- [ ] Criar helper `test/vitest/helpers/test-store.ts`:

```typescript
import { setActivePinia, createPinia } from 'pinia'
import { beforeEach } from 'vitest'

export function setupStoreTests() {
  beforeEach(() => {
    setActivePinia(createPinia())
  })
}
```

- [ ] Criar testes para cada store em `src/stores/`:

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

### Etapa 4.2: Testar Componentes Criticos

- [ ] Identificar e listar componentes criticos em `src/components/`
- [ ] Criar testes para cada componente usando o padrao:

```typescript
import { describe, it, expect } from 'vitest'
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

---

## Fase 5: Page Objects e Testes E2E Avancados

### Etapa 5.1: Criar Page Objects

- [ ] Criar Page Object para cada pagina principal:

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

### Etapa 5.2: Testes de Fluxos Criticos

- [ ] Testar fluxos criticos do usuario
- [ ] Incluir testes de autenticacao (se aplicavel)
- [ ] Testar navegacao entre paginas

### Etapa 5.3: Testes de Responsividade

- [ ] Testar em diferentes viewports usando projects do Playwright

---

## Boas Praticas

### Vitest / Testes Unitarios

1. **Co-localizacao**: Mantenha testes proximos aos arquivos que testam (`Component.spec.ts` junto de `Component.vue`)
2. **Descricao clara**: Use `describe` e `it` com descricoes que formem frases legiveis
3. **AAA Pattern**: Arrange (preparar), Act (agir), Assert (verificar)
4. **Mocks isolados**: Limpe mocks apos cada teste com `vi.clearAllMocks()`
5. **Evite shallowMount**: Prefira `mount` para testes mais realistas
6. **Teste comportamento**: Foque em inputs/outputs, nao em implementacao interna

### Playwright / Testes E2E

1. **Page Object Model**: Abstraia interacoes com paginas em classes
2. **data-testid**: Use atributos `data-testid` para seletores robustos
3. **Evite timeouts fixos**: Use `waitFor*` em vez de `page.waitForTimeout()`
4. **Testes independentes**: Cada teste deve funcionar isoladamente
5. **Paralelizacao**: Escreva testes que possam rodar em paralelo
6. **Screenshots em falhas**: Configure para capturar evidencias de erros

---

## Proximos Passos e Evolucao

Com a base pronta, aqui estao sugestoes para evoluir os testes:

- **Cobertura de Codigo**: Adicione a flag `--coverage` e monitore a evolucao
- **Mocking de APIs**: Use `msw` (Mock Service Worker) para simular respostas de API
- **Testes Visuais**: Explore o `toHaveScreenshot()` do Playwright para detectar regressoes visuais
- **Pre-commit Hooks**: Configure husky para rodar testes antes de commits

---

## Estrutura Final de Diretorios

```
├── e2e/
│   ├── fixtures/
│   │   └── test-base.ts
│   ├── pages/
│   │   ├── BasePage.ts
│   │   └── [PageName]Page.ts
│   ├── tests/
│   │   └── app.spec.ts
│   └── utils/
│       └── helpers.ts
├── test/
│   └── vitest/
│       ├── helpers/
│       │   ├── mount-quasar.ts
│       │   └── test-store.ts
│       └── setup.ts
├── src/
│   ├── components/
│   │   ├── MyComponent.vue
│   │   └── __tests__/
│   │       └── MyComponent.spec.ts
│   ├── composables/
│   │   └── __tests__/
│   │       └── useI18n.spec.ts
│   └── stores/
│       └── __tests__/
│           └── myStore.spec.ts
├── vitest.config.ts
├── playwright.config.ts
└── package.json
```

---

## Metricas de Sucesso

| Metrica | Meta Inicial | Meta Final |
|---------|--------------|------------|
| Cobertura de Statements | 60% | 80% |
| Cobertura de Branches | 60% | 75% |
| Cobertura de Functions | 60% | 80% |
| Cobertura de Lines | 60% | 80% |
| Testes E2E passando | 100% | 100% |
| Tempo de execucao CI | < 10min | < 5min |

---

## Referencias

- [Vue.js Testing Guide](https://vuejs.org/guide/scaling-up/testing)
- [Vitest Documentation](https://vitest.dev/)
- [Vue Test Utils](https://test-utils.vuejs.org/)
- [Playwright Documentation](https://playwright.dev/)
- [Quasar Testing](https://testing.quasar.dev/)
