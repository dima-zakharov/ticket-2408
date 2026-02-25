use serde_json::json;

pub fn base_url() -> String {
    std::env::var("BASE_URL").expect("BASE_URL must be set")
}

pub fn token() -> String {
    std::env::var("TOKEN").expect("TOKEN must be set")
}

pub fn create_resource_payload() -> serde_json::Value {
    json!({
        "resource": {
            "uri": "http://www.listru-test-unique.site",
            "name": "listru-test-unique",
            "description": "listru-test-unique",
            "content": "test"
        }
    })
}
