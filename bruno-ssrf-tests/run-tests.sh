#!/usr/bin/env -S bash
# Run SSRF security tests using curl (Bruno test scenarios)
# 
# IMPORTANT: Gateway must be started with SSRF protection enabled:
#   SSRF_PROTECTION_ENABLED=true \
#   SSRF_BLOCK_PRIVATE_IPS=true \
#   SSRF_BLOCK_LOCALHOST=true \
#   SSRF_BLOCK_CLOUD_METADATA=true \
#   SSRF_ALLOWED_PROTOCOLS=http,https \
#   make dev

set -ueo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load environment
source ../00-env.sh

# Counters
PASSED=0
FAILED=0
TOTAL=0

# Test function
run_test() {
    local name="$1"
    local uri="$2"
    local expected_status="$3"  # e.g., "400 403"
    
    TOTAL=$((TOTAL + 1))
    
    echo -n "Testing: $name ... "
    
    # Make request
    response=$(curl -s -w "\n%{http_code}" -X POST "http://localhost:4444/resources/" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"resource\":{\"uri\":\"$uri\",\"name\":\"test-$TOTAL\",\"content\":\"test\"}}")
    
    # Extract status code (last line)
    status=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    # Check if status matches expected
    matched=0
    for expected in $expected_status; do
        if [[ "$status" == "$expected" ]]; then
            matched=1
            break
        fi
    done
    
    if [[ $matched -eq 1 ]]; then
        echo "PASS (Status: $status)"
        PASSED=$((PASSED + 1))
    else
        echo "FAIL (Expected: $expected_status, Got: $status)"
        FAILED=$((FAILED + 1))
    fi
}

echo "========================================"
echo "SSRF Security Tests (Bruno Scenarios)"
echo "========================================"
echo ""
echo "NOTE: Gateway must be restarted with SSRF env vars for tests to pass!"
echo ""

# TC-SSRF-001: AWS Metadata
echo "--- TC-SSRF-001: AWS Metadata Endpoint ---"
run_test "AWS Metadata Direct" "http://169.254.169.254/latest/meta-data/" "400 403"
run_test "AWS IAM Credentials" "http://169.254.169.254/latest/meta-data/iam/security-credentials/" "400 403"
run_test "AWS User Data" "http://169.254.169.254/latest/user-data" "400 403"
echo ""

# TC-SSRF-004: Private IPs
echo "--- TC-SSRF-004: Private IP Ranges ---"
run_test "Private IP 10.0.0.1" "http://10.0.0.1/admin" "400 403"
run_test "Private IP 172.16.0.1" "http://172.16.0.1/internal" "400 403"
run_test "Private IP 192.168.1.1" "http://192.168.1.1/" "400 403"
echo ""

# TC-SSRF-005: Localhost
echo "--- TC-SSRF-005: Localhost ---"
run_test "Localhost 127.0.0.1" "http://127.0.0.1:8000/admin" "400 403"
run_test "Localhost hostname" "http://localhost:3000/" "400 403"
run_test "Localhost 0.0.0.0" "http://0.0.0.0:8080/" "400 403"
echo ""

# TC-SSRF-007: Dangerous Protocols
echo "--- TC-SSRF-007: Dangerous Protocols ---"
run_test "file:// protocol" "file:///etc/passwd" "400 403"
run_test "gopher:// protocol" "gopher://evil.com:25/" "400 403"
run_test "dict:// protocol" "dict://evil.com:11111/" "400 403"
run_test "ldap:// protocol" "ldap://evil.com/" "400 403"
echo ""

# Summary
echo "========================================"
echo "Summary"
echo "========================================"
echo "Total:  $TOTAL"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi
