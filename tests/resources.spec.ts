import { test, expect } from "@playwright/test";

test.describe("Resources API", () => {
	test.describe.configure({ mode: "serial" });

	let createdResourceId: string | null = null;
	const testResource = {
		resource: {
			uri: "http://www.listru-test-unique.site",
			name: "listru-test-unique",
			description: "listru-test-unique",
			content: "test",
		},
	};

	test.afterEach(async ({ request }) => {
		// Cleanup: delete created resource after each test
		// Only delete if this test actually created the resource
		if (createdResourceId) {
			await request.delete(`/resources/${createdResourceId}`, {
				headers: {
					Authorization: `Bearer ${process.env.TOKEN}`,
				},
			});
			createdResourceId = null;
		}
	});

	test("health check", async ({ request }) => {
		const response = await request.get("/health", {
			headers: {
				Authorization: `Bearer ${process.env.TOKEN}`,
			},
		});

		expect(response.ok(), `Failed with status ${response.status()}`).toBeTruthy();
	});

	test("add resource", async ({ request }) => {
		const response = await request.post("/resources", {
			headers: {
				Authorization: `Bearer ${process.env.TOKEN}`,
			},
			data: testResource,
		});

		expect(
			[200, 409].includes(response.status()),
			`Failed with status ${response.status()}`,
		).toBeTruthy();

		if (response.status() === 200) {
			const body = await response.json();
			createdResourceId = body.id;
		}
	});

	test("get resources", async ({ request }) => {
		const response = await request.get("/resources", {
			headers: {
				Authorization: `Bearer ${process.env.TOKEN}`,
			},
		});

		expect(response.ok(), `Failed with status ${response.status()}`).toBeTruthy();

		const resources = await response.json();
		expect(Array.isArray(resources)).toBeTruthy();

		// Find test resource (don't store for deletion - let delete test handle it)
		const myResource = resources.find(
			(r: { name: string }) => r.name === "listru-test-unique",
		);

		if (myResource) {
			console.log("Found Resource ID: " + myResource.id);
		}
	});

	test("delete resource", async ({ request }) => {
		// First, ensure we have a resource to delete
		const getResourcesResponse = await request.get("/resources", {
			headers: {
				Authorization: `Bearer ${process.env.TOKEN}`,
			},
		});

		const resources = await getResourcesResponse.json();
		
		// Try to find test resource by name
		let myResource = resources.find(
			(r: { name: string }) => r.name === "listru-test-unique",
		);
		
		// If not found, try to create it first
		if (!myResource) {
			const createResponse = await request.post("/resources", {
				headers: {
					Authorization: `Bearer ${process.env.TOKEN}`,
				},
				data: testResource,
			});
			
			if (createResponse.status() === 200) {
				const body = await createResponse.json();
				myResource = { id: body.id };
			} else if (createResponse.status() === 409) {
				// Resource exists but wasn't in the list - fetch again
				const retryResponse = await request.get("/resources", {
					headers: {
						Authorization: `Bearer ${process.env.TOKEN}`,
					},
				});
				const retryResources = await retryResponse.json();
				myResource = retryResources.find(
					(r: { name: string }) => r.name === "listru-test-unique",
				);
			}
		}

		// Skip test if no resource found
		test.skip(!myResource, "No test resource found to delete");

		const response = await request.delete(`/resources/${myResource.id}`, {
			headers: {
				Authorization: `Bearer ${process.env.TOKEN}`,
			},
		});

		expect(response.ok(), `Failed with status ${response.status()}`).toBeTruthy();
	});
});
