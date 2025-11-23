import { test as base } from '@playwright/test'

export const test = base.extend<{
  // Add custom fixtures here as needed
}>({
  // Example of a custom fixture for authentication:
  // authenticatedPage: async ({ page }, use) => {
  //   await page.goto('/login')
  //   await page.fill('[data-testid="email"]', 'user@example.com')
  //   await page.fill('[data-testid="password"]', 'password')
  //   await page.click('[data-testid="submit"]')
  //   await use(page)
  // }
})

export { expect } from '@playwright/test'
