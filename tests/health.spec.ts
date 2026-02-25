import { test, expect } from "@playwright/test";

test("system is healthy", async ({ request }) => {
	const token = process.env.TOKEN;

	const response = await request.get("/health", {
		headers: {
			Authorization: `Bearer ${token}`,
		},
	});

	expect(response.ok(), `Failed with status ${response.status()}`).toBeTruthy();

	const body = await response.json();
	expect(body).toEqual({ status: "healthy" });
});
