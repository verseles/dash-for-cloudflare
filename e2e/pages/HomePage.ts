import { BasePage } from './BasePage'
import { Page, Locator, expect } from '@playwright/test'

export class HomePage extends BasePage {
  readonly header: Locator
  readonly menuDrawer: Locator
  readonly settingsLink: Locator
  readonly dnsLink: Locator

  constructor(page: Page) {
    super(page)
    this.header = page.locator('.q-header')
    this.menuDrawer = page.locator('.q-drawer')
    this.settingsLink = page.getByRole('link', { name: /settings/i })
    this.dnsLink = page.getByRole('link', { name: /dns/i })
  }

  async expectLoaded(): Promise<void> {
    await expect(this.page.locator('#q-app')).toBeVisible()
    await expect(this.page.locator('.q-layout')).toBeVisible()
  }

  async goToSettings(): Promise<void> {
    await this.settingsLink.click()
    await this.page.waitForURL(/.*settings/)
  }

  async goToDns(): Promise<void> {
    await this.dnsLink.click()
    await this.page.waitForURL(/.*dns/)
  }

  async openMenu(): Promise<void> {
    const menuButton = this.page.locator('.q-btn').filter({ hasText: '' }).first()
    if (await menuButton.isVisible()) {
      await menuButton.click()
    }
  }
}
