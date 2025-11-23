import { test, expect } from '@playwright/test'

test.describe('App Loading', () => {
  test('should load the application', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    // Check that the app container is present
    await expect(page.locator('#q-app')).toBeVisible()
  })

  test('should display main layout', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    // App should load with Quasar layout
    await expect(page.locator('.q-layout')).toBeVisible()
  })
})

test.describe('Navigation', () => {
  test('should navigate to settings page', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    // Look for settings link/button in the layout
    const settingsLink = page.getByRole('link', { name: /settings/i })
    if (await settingsLink.isVisible()) {
      await settingsLink.click()
      await expect(page).toHaveURL(/.*settings/)
    }
  })
})
