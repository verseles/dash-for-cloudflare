import { test, expect } from '@playwright/test'

test.describe('Responsive Design', () => {
  test('should display correctly on desktop', async ({ page }) => {
    await page.setViewportSize({ width: 1920, height: 1080 })
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    // Desktop should show full layout
    await expect(page.locator('.q-layout')).toBeVisible()
  })

  test('should display correctly on tablet', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 })
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    await expect(page.locator('.q-layout')).toBeVisible()
  })

  test('should display correctly on mobile', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 })
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    await expect(page.locator('.q-layout')).toBeVisible()
  })

  test('should handle viewport resize', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    // Start with desktop
    await page.setViewportSize({ width: 1920, height: 1080 })
    await expect(page.locator('.q-layout')).toBeVisible()

    // Resize to mobile
    await page.setViewportSize({ width: 375, height: 667 })
    await expect(page.locator('.q-layout')).toBeVisible()
  })
})
