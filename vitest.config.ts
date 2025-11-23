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
    include: [
      'src/**/*.{test,spec}.{js,ts}',
      'src/**/*.vitest.{test,spec}.{js,ts}',
      'test/**/*.{test,spec}.{js,ts}'
    ],
    exclude: ['node_modules', 'dist', 'e2e'],
    setupFiles: ['test/vitest/setup-file.ts'],
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
        statements: 1,
        branches: 30,
        functions: 30,
        lines: 1
      }
    }
  }
})
