import { BasePage } from './BasePage';
import { Page, Locator, expect } from '@playwright/test';

export class DnsPage extends BasePage {
  readonly zoneSelector: Locator;
  readonly dnsRecordsList: Locator;
  readonly addRecordButton: Locator;
  readonly searchInput: Locator;

  constructor(page: Page) {
    super(page);
    this.zoneSelector = page.locator('.q-select').first();
    this.dnsRecordsList = page.locator('.q-list');
    this.addRecordButton = page.getByRole('button', { name: /add/i });
    this.searchInput = page.locator('input[type="search"], input[placeholder*="search" i]');
  }

  override async navigate(): Promise<void> {
    await super.navigate('/dns');
  }

  async expectLoaded(): Promise<void> {
    await expect(this.page).toHaveURL(/.*dns/);
    await this.waitForPageLoad();
  }

  async selectZone(zoneName: string): Promise<void> {
    await this.zoneSelector.click();
    await this.page.getByRole('option', { name: zoneName }).click();
  }

  async getRecordCount(): Promise<number> {
    const records = this.page.locator('.q-item');
    return records.count();
  }

  async searchRecords(query: string): Promise<void> {
    if (await this.searchInput.isVisible()) {
      await this.searchInput.fill(query);
    }
  }
}
