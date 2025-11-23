import { test, expect } from '@playwright/test';
import { HomePage } from '../pages/HomePage';

test.describe('Navigation', () => {
  test('should load home page', async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.navigate('/');
    await homePage.expectLoaded();
  });

  test('should have main layout elements', async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.navigate('/');
    await homePage.waitForPageLoad();

    // Check for main layout container
    await expect(page.locator('.q-layout')).toBeVisible();
  });

  test('should navigate to settings page', async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.navigate('/');
    await homePage.waitForPageLoad();

    // Try to find and click settings link
    const settingsLink = page.getByRole('link', { name: /settings/i });
    if (await settingsLink.isVisible()) {
      await settingsLink.click();
      await expect(page).toHaveURL(/.*settings/);
    }
  });
});
