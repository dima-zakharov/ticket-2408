# SSRF Security Tests - Bruno Collection

This is a Bruno collection for testing SSRF (Server-Side Request Forgery) protection in the MCP Gateway.

## Prerequisites

1. Install Bruno: https://www.usebruno.com/downloads
2. Gateway must be running on `http://localhost:4444`
3. Valid JWT token in `bruno.env`

## Test Coverage

| File | Test Cases | Description |
|------|------------|-------------|
| `01-aws-metadata.bru` | TC-SSRF-001 | AWS metadata endpoint protection |
| `02-private-ips.bru` | TC-SSRF-004 | Private IP range blocking (10/8, 172.16/12, 192.168/16) |
| `03-localhost.bru` | TC-SSRF-005 | Localhost and 0.0.0.0 blocking |
| `04-dangerous-protocols.bru` | TC-SSRF-007 | Protocol blocking (file, gopher, dict, ldap) |

## Running Tests

### Using Bruno CLI

```bash
# Install bru CLI
npm install -g @usebruno/cli

# Run all tests
bru run ./bruno-ssrf-tests --env Default

# Run specific test file
bru run ./bruno-ssrf-tests/01-aws-metadata.bru --env Default
```

### Using Bruno UI

1. Open Bruno
2. Click "Import Collection"
3. Select the `bruno-ssrf-tests` folder
4. Select the "Default" environment
5. Click "Run Collection"

### Using Shell Script (No Bruno required)

```bash
cd bruno-ssrf-tests
./run-tests.sh
```

## Expected Results

All SSRF protection tests should return:
- **Status 400** (Bad Request) or **403** (Forbidden)
- Response body should contain SSRF protection keywords

## Environment Variables

Edit `bruno.env` to configure:

```json
{
  "base_url": "http://localhost:4444",
  "token": "your-jwt-token-here"
}
```

## Generate New Token

```bash
source ./00-env.sh
echo $TOKEN
```

Update `bruno.env` with the new token value.

## Starting Gateway with SSRF Protection

The gateway must be restarted with SSRF environment variables:

```bash
# Stop existing gateway
pkill -f mcpgateway

# Start with SSRF protection
SSRF_PROTECTION_ENABLED=true \
SSRF_BLOCK_PRIVATE_IPS=true \
SSRF_BLOCK_LOCALHOST=true \
SSRF_BLOCK_CLOUD_METADATA=true \
SSRF_ALLOWED_PROTOCOLS=http,https \
make dev
```

## Test Format

Each `.bru` file contains one or more test requests in Bruno's declarative format:

```bru
meta {
  name: Test Name
  method: POST
  seq: 1
}

get {
  url: {{base_url}}/resources/
  req {
    headers {
      Authorization: Bearer {{token}}
      Content-Type: application/json
    }
    body {
      json {
        resource {
          uri: http://malicious-url/
          name: test-name
          content: test
        }
      }
    }
  }

  assert {
    res.status in [400, 403]
    res.body ~ /SSRF|blocked/i
  }
}
```

## Troubleshooting

### Tests failing with 401
- Token expired - generate new token and update `bruno.env`

### Tests failing with 404
- Check gateway is running: `curl http://localhost:4444/health`
- Verify endpoint path is correct

### Tests returning 200 instead of 400/403
- Gateway not started with SSRF protection enabled
- Restart gateway with SSRF environment variables (see above)

## Related Files

- `ssrf-cloud-metadata.yaml` - Original Nuclei template
- `ssrf-private-ips.yaml` - Original Nuclei template
- `00-env.sh` - Environment configuration
- `run-scenarios.sh` - Nuclei test runner
