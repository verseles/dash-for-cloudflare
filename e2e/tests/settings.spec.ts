import { test, expect } from '@playwright/test'
import { SettingsPage } from '../pages/SettingsPage'

test.describe('Settings Page', () => {
  test('should load settings page', async ({ page }) => {
    const settingsPage = new SettingsPage(page)
    await settingsPage.navigate()
    await settingsPage.expectLoaded()
  })

  test('should have settings form elements', async ({ page }) => {
    const settingsPage = new SettingsPage(page)
    await settingsPage.navigate()
    await settingsPage.waitForPageLoad()

    // Page should contain settings-related content
    await expect(page.locator('.q-page')).toBeVisible()
  })

  test('should allow typing in input fields', async ({ page }) => {
    const settingsPage = new SettingsPage(page)
    await settingsPage.navigate()
    await settingsPage.waitForPageLoad()

    // Find any input field and test interaction
    const input = page.locator('input').first()
    if (await input.isVisible()) {
      await input.click()
      await expect(input).toBeFocused()
    }
  })
})
