# SSRF Test Templates for Nuclei

Comprehensive SSRF (Server-Side Request Forgery) test templates for the MCP Context Forge gateway.

## Test Coverage

| Template | Test Cases | Description |
|----------|------------|-------------|
| `ssrf-cloud-metadata.yaml` | TC-SSRF-001 to 003 | AWS, GCP, Azure metadata protection |
| `ssrf-private-ips.yaml` | TC-SSRF-004 | Private IP range blocking (10/8, 172.16/12, 192.168/16) |
| `ssrf-localhost.yaml` | TC-SSRF-005 to 006 | Localhost and IPv6 localhost blocking |
| `ssrf-dangerous-protocols.yaml` | TC-SSRF-007 | Protocol blocking (file, gopher, dict, ldap, etc.) |
| `ssrf-bypass-attempts.yaml` | TC-SSRF-008 | URL parsing bypass attempts (encoding, IP formats) |
| `ssrf-dns-rebinding.yaml` | TC-SSRF-009 | DNS rebinding protection |
| `ssrf-integration.yaml` | TC-SSRF-010 to 013 | Integration point SSRF (registration, resources, webhooks, redirects) |
| `ssrf-allowlist.yaml` | TC-SSRF-014 to 015 | Valid URLs and allowlist mode |

## Prerequisites

1. Install Nuclei:
```bash
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
```

2. Set environment variables:
```bash
export TOKEN="your-jwt-token"
export ADMIN_TOKEN="your-admin-jwt-token"
export BASE_URL="http://localhost:8000"
```

## Running Tests

### Run all SSRF tests:
```bash
nuclei -t . -var TOKEN=$TOKEN -var ADMIN_TOKEN=$ADMIN_TOKEN -var BASE_URL=$BASE_URL
```

### Run specific test category:
```bash
# Cloud metadata tests
nuclei -t ssrf-cloud-metadata.yaml -var TOKEN=$TOKEN -var BASE_URL=$BASE_URL

# Private IP tests
nuclei -t ssrf-private-ips.yaml -var TOKEN=$TOKEN -var BASE_URL=$BASE_URL

# Bypass attempt tests
nuclei -t ssrf-bypass-attempts.yaml -var TOKEN=$TOKEN -var BASE_URL=$BASE_URL
```

### Run with output file:
```bash
nuclei -t . \
  -var TOKEN=$TOKEN \
  -var ADMIN_TOKEN=$ADMIN_TOKEN \
  -var BASE_URL=$BASE_URL \
  -o ssrf-test-results.txt
```

### Run with verbose output:
```bash
nuclei -t . -v -var TOKEN=$TOKEN -var BASE_URL=$BASE_URL
```

## Expected Results

All SSRF protection tests should return:
- **Status 400** (Bad Request) or **403** (Forbidden)
- Response body may contain SSRF protection messages

Valid external URL tests should return:
- **Status 200** (OK)

## Test Matrix

```
┌─────────────────────────────┬──────────┬──────────┬──────────┬──────────┐
│ Test Category               │ Requests │ Expected │ Critical │ Status   │
├─────────────────────────────┼──────────┼──────────┼──────────┼──────────┤
│ Cloud Metadata              │ 7        │ 400/403  │ YES      │ MUST     │
│ Private IPs                 │ 7        │ 400/403  │ YES      │ MUST     │
│ Localhost                   │ 10       │ 400/403  │ YES      │ MUST     │
│ Dangerous Protocols         │ 11       │ 400/403  │ YES      │ MUST     │
│ Bypass Attempts             │ 16       │ 400/403  │ YES      │ MUST     │
│ DNS Rebinding               │ 8        │ 400/403  │ YES      │ MUST     │
│ Integration Points          │ 12       │ 400/403  │ YES      │ MUST     │
│ Valid URLs                  │ 12       │ 200      │ YES      │ MUST     │
├─────────────────────────────┼──────────┼──────────┼──────────┼──────────┤
│ TOTAL                       │ 83       │ -        │ -        │ -        │
└─────────────────────────────┴──────────┴──────────┴──────────┴──────────┘
```

## Customization

### Add custom headers:
```bash
nuclei -t . -H "X-Custom-Header: value" -var TOKEN=$TOKEN -var BASE_URL=$BASE_URL
```

### Rate limiting:
```bash
nuclei -t . -rate-limit 10 -var TOKEN=$TOKEN -var BASE_URL=$BASE_URL
```

### Timeout adjustment:
```bash
nuclei -t . -timeout 30 -var TOKEN=$TOKEN -var BASE_URL=$BASE_URL
```

## Troubleshooting

### Tests failing with connection errors:
```bash
# Check gateway is running
curl -s http://localhost:8000/health

# Check token is valid
curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8000/api/me
```

### Tests not matching expected status:
```bash
# Run with verbose to see full response
nuclei -t ssrf-cloud-metadata.yaml -v -var TOKEN=$TOKEN -var BASE_URL=$BASE_URL
```

## Related Files

- `mcpgateway/utils/url_validator.py` - URL validation logic
- `mcpgateway/services/resource_service.py` - Resource fetching
- `mcpgateway/services/gateway_service.py` - Gateway registration

## References

- [OWASP SSRF](https://owasp.org/www-community/attacks/Server_Side_Request_Forgery)
- [Nuclei Documentation](https://docs.nuclei.sh/)
- [GitHub Issue #2408](https://github.com/IBM/mcp-context-forge/issues/2408)
