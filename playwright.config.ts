import { defineConfig } from "@playwright/test";

export default defineConfig({
	testDir: "./tests",
	testMatch: "**/*.spec.ts",

	fullyParallel: true,
	reporter: [
		["list"],
		["html", { outputFolder: "test-results", open: "never" }],
		["json", { outputFile: "test-results/test-results.json" }],
	],
	use: {
		baseURL: process.env.BASE_URL || "http://localhost:4444",
		extraHTTPHeaders: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
	},
});
