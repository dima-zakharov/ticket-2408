use restest::{path, Context, Request};
use serde::{Deserialize, Serialize};
use http::StatusCode;

use ticket_2408::{base_url, create_resource_payload, token};

fn context() -> Context {
    Context::new()
}

#[derive(Debug, Serialize)]
struct ResourcePayload {
    resource: ResourceData,
}

#[derive(Debug, Serialize)]
struct ResourceData {
    uri: String,
    name: String,
    description: String,
    content: String,
}

#[derive(Debug, Deserialize)]
struct HealthResponse {
    status: String,
}

#[derive(Debug, Deserialize)]
struct Resource {
    id: String,
    name: String,
}

#[derive(Debug, Deserialize)]
struct DeleteResponse {
    status: String,
}

#[tokio::test]
async fn smoke_test_health() {
    let request = Request::get(path![Box::leak(format!("{}/health", base_url()).into_boxed_str())]).with_body(());

    let body: HealthResponse = context()
        .run(request)
        .await
        .expect_status(StatusCode::OK)
        .await;

    assert_eq!(body.status, "healthy");
}

#[tokio::test]
async fn smoke_test_resources_full_flow() {
    let base: &'static str = Box::leak(base_url().into_boxed_str());
    let auth_token = token();
    let ctx = context();

    // 1. Create resource
    let payload = create_resource_payload();
    let resource_data = payload.as_object().unwrap().get("resource").unwrap();
    let create_payload = ResourcePayload {
        resource: ResourceData {
            uri: resource_data["uri"].as_str().unwrap().to_string(),
            name: resource_data["name"].as_str().unwrap().to_string(),
            description: resource_data["description"].as_str().unwrap().to_string(),
            content: resource_data["content"].as_str().unwrap().to_string(),
        },
    };

    let create_request = Request::post(path![base, "resources"])
        .with_header("Authorization", &format!("Bearer {}", auth_token))
        .with_body(&create_payload);

    let _create_response: serde_json::Value = ctx
        .run(create_request)
        .await
        .expect_status(StatusCode::OK)
        .await;

    // 2. List resources
    let list_request = Request::get(path![base, "resources"])
        .with_header("Authorization", &format!("Bearer {}", auth_token))
        .with_body(());

    let resources: Vec<Resource> = ctx
        .run(list_request)
        .await
        .expect_status(StatusCode::OK)
        .await;

    // Find the target resource by name
    let target = resources
        .iter()
        .find(|r| r.name == "listru-test-unique")
        .expect("Resource 'listru-test-unique' not found");

    let resource_id = &target.id;

    // 3. Delete resource using grillon
    use grillon::Grillon;
    use serde_json::Value;

    let auth_header = format!("Bearer {}", auth_token);
    let assert = Grillon::new(&base)
        .unwrap()
        .delete(&format!("/resources/{}", resource_id))
        .headers(vec![(
            "Authorization",
            auth_header.as_str(),
        )])
        .assert()
        .await
        .status(grillon::dsl::http::is_success());

    let json_value: Value = assert.json
        .expect("Expected JSON response")
        .expect("Response body is empty");
    let delete_response: DeleteResponse = serde_json::from_value(json_value)
        .expect("Failed to deserialize response");

    assert_eq!(delete_response.status, "success");
}
