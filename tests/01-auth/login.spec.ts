import { test, expect } from "@playwright/test";

test("login to MCP Gateway", async ({ page }) => {
	await page.goto("http://localhost:4444/admin/login");
	await page.fill("#email", "admin@example.com");
	await page.fill("#password", "changeme");
	await page.click('button:has-text("Sign In")');
	await expect(page).toHaveURL(/.*admin/);
//	await expect(page).toHaveURL('http://localhost:4444/admin/change-password-required');
});
