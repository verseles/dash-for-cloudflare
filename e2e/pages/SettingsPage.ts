import { BasePage } from './BasePage'
import { Page, Locator, expect } from '@playwright/test'

export class SettingsPage extends BasePage {
  readonly apiTokenInput: Locator
  readonly languageSelect: Locator
  readonly saveButton: Locator

  constructor(page: Page) {
    super(page)
    this.apiTokenInput = page.locator('input[type="password"], input[type="text"]').first()
    this.languageSelect = page.locator('.q-select').first()
    this.saveButton = page.getByRole('button', { name: /save/i })
  }

  async navigate(): Promise<void> {
    await super.navigate('/settings')
  }

  async expectLoaded(): Promise<void> {
    await expect(this.page).toHaveURL(/.*settings/)
    await this.waitForPageLoad()
  }

  async setApiToken(token: string): Promise<void> {
    await this.apiTokenInput.fill(token)
  }

  async clearApiToken(): Promise<void> {
    await this.apiTokenInput.clear()
  }
}
