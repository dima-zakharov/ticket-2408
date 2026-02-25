GET {{base_url}}/health
HTTP 200

[Asserts]
jsonpath "$.status" == "healthy"


POST {{base_url}}/resources
Authorization: Bearer {{token}}
{
    "resource": {
        "uri": "http://www.listru-test-unique.site",
        "name": "listru-test-unique",
        "description": "listru-test-unique",
        "content": "test"
    }
}

HTTP *
[Asserts]
status toString matches "^(200|409)$"


GET {{base_url}}/resources
Authorization: Bearer {{token}}
HTTP 200

[Captures]
# Find the specific resource by name and grab its unique ID
del_id: jsonpath "$[?(@.name == 'listru-test-unique')].id" nth 0

[Asserts]
jsonpath "$" isList
jsonpath "$" count > 0


# 4. Cleanup: Delete the resource
DELETE {{base_url}}/resources/{{del_id}}
Authorization: Bearer {{token}}
HTTP 200

[Asserts]
jsonpath "$.status" == "success"
