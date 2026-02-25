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
    let base = base_url();
    let request = Request::get(path![&base, "health"]).with_body(());

    let body: HealthResponse = context()
        .run(request)
        .await
        .expect_status(StatusCode::OK)
        .await;

    assert_eq!(body.status, "healthy");
}

#[tokio::test]
async fn smoke_test_resources_full_flow() {
    let base = base_url();
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

    let create_request = Request::post(path![&base, "resources"])
        .with_header("Authorization", &format!("Bearer {}", auth_token))
        .with_body(&create_payload);

    let _create_response: serde_json::Value = ctx
        .run(create_request)
        .await
        .expect_status(StatusCode::OK)
        .await;

    // 2. List resources
    let list_request = Request::get(path![&base, "resources"])
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

    // 3. Delete resource (using POST with _method override since restest doesn't support DELETE)
    // Note: restest 0.1.0 only supports GET and POST. For DELETE, we'll use grillon instead.
    use grillon::{HttpMethod, Grillon};
    
    let delete_response: DeleteResponse = Grillon::new()
        .base_url(&base)
        .request(HttpMethod::Delete)
        .path(&format!("/resources/{}", resource_id))
        .header("Authorization", &format!("Bearer {}", auth_token))
        .send()
        .await
        .expect_status(StatusCode::OK)
        .await;

    assert_eq!(delete_response.status, "success");
}
