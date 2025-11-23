import { Page } from '@playwright/test'

/**
 * Wait for the app to be fully loaded
 */
export async function waitForAppReady(page: Page): Promise<void> {
  await page.waitForLoadState('networkidle')
  // Wait for Vue app to be mounted
  await page.waitForSelector('#q-app', { state: 'visible' })
}

/**
 * Helper to fill form fields
 */
export async function fillFormField(
  page: Page,
  selector: string,
  value: string
): Promise<void> {
  await page.locator(selector).fill(value)
}

/**
 * Helper to click a button by text
 */
export async function clickButtonByText(page: Page, text: string): Promise<void> {
  await page.getByRole('button', { name: text }).click()
}
