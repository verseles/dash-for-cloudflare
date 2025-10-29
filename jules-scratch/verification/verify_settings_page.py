from playwright.sync_api import Page, expect

def test_settings_page(page: Page):
    page.goto("http://127.0.0.1:4000")

    # Click on the menu and then on the "Settings" link
    page.get_by_role("button", name="Menu").click()
    page.get_by_role("link", name="Settings").click()

    # Check if the URL is correct
    expect(page).to_have_url("http://127.0.0.1:4000/settings")

    # Check if the "Go to DNS Management" button navigates to the correct URL
    page.get_by_role("button", name="Go to DNS Management").click()
    expect(page).to_have_url("http://127.0.0.1:4000/dns/records")

    # Go back to the settings page
    page.go_back()

    # Check if the Account ID input field is present
    expect(page.get_by_label("Cloudflare Account ID")).to_be_visible()

    page.screenshot(path="jules-scratch/verification/settings-page.png")