#!/bin/bash
set -euo pipefail

# Test CA selection and fail-closed behavior with locally generated certificates.
script="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/thumbprint.sh"
readonly script
REAL_OPENSSL="$(command -v openssl)"
export REAL_OPENSSL
test_dir="$(mktemp -d)"
readonly test_dir
cleanup() {
    rm -f "$test_dir"/*.pem "$test_dir"/*.key "$test_dir"/*.csr \
        "$test_dir/ca.cnf" "$test_dir/out" "$test_dir/err" "$test_dir/openssl.log" \
        "$test_dir/bin/openssl"
    rmdir "$test_dir/bin" "$test_dir/empty" "$test_dir"
}
trap cleanup EXIT
mkdir "$test_dir/bin" "$test_dir/empty"
umask 077

printf 'basicConstraints=critical,CA:TRUE\n' > "$test_dir/ca.cnf"
"$REAL_OPENSSL" req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
    -nodes -keyout "$test_dir/root.key" -out "$test_dir/root.pem" \
    -days 1 -subj /CN=test-root -addext basicConstraints=critical,CA:TRUE \
    > "$test_dir/openssl.log" 2>&1
for name in intermediate leaf; do
    "$REAL_OPENSSL" req -new -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
        -nodes -keyout "$test_dir/$name.key" -out "$test_dir/$name.csr" \
        -subj "/CN=test-$name" >> "$test_dir/openssl.log" 2>&1
done
"$REAL_OPENSSL" x509 -req -in "$test_dir/intermediate.csr" \
    -CA "$test_dir/root.pem" -CAkey "$test_dir/root.key" -set_serial 2 \
    -days 1 -extfile "$test_dir/ca.cnf" -out "$test_dir/intermediate.pem" \
    >> "$test_dir/openssl.log" 2>&1
"$REAL_OPENSSL" x509 -req -in "$test_dir/leaf.csr" \
    -CA "$test_dir/intermediate.pem" -CAkey "$test_dir/intermediate.key" -set_serial 3 \
    -days 1 -out "$test_dir/leaf.pem" >> "$test_dir/openssl.log" 2>&1

cat > "$test_dir/bin/openssl" <<'STUB'
#!/bin/bash
set -euo pipefail
if [[ "$1" == s_client ]]; then
    [[ "$*" == *"-verify_return_error"* && "$*" == *"-verify_hostname $TEST_SERVER"* ]]
    [[ "$*" == *"-connect $TEST_SERVER:443"* && "$*" == *"-servername $TEST_SERVER"* ]]
    if [[ "${TEST_MODE:-}" == tls-failure ]]; then
        printf 'Simulated TLS verification failure.\n' >&2
        exit 1
    fi
    cat "$TEST_CHAIN"
elif [[ "${TEST_MODE:-}" == bad-fingerprint && "$*" == *"-fingerprint"* ]]; then
    printf 'sha1 Fingerprint=invalid\n'
elif [[ "${TEST_MODE:-}" == fingerprint-failure && "$*" == *"-fingerprint"* ]]; then
    printf 'sha1 Fingerprint=0123456789012345678901234567890123456789\n'
    printf 'Simulated fingerprint command failure.\n' >&2
    exit 17
else
    exec "$REAL_OPENSSL" "$@"
fi
STUB
chmod 755 "$test_dir/bin/openssl"
export PATH="$test_dir/bin:$PATH"
export TEST_CHAIN="$test_dir/chain.pem"
export TEST_SERVER=s3-ap-southeast-1.amazonaws.com
expected="$("$REAL_OPENSSL" x509 -in "$test_dir/intermediate.pem" -sha1 -noout -fingerprint |
    cut -d '=' -f 2 | tr -d ':' | tr '[:upper:]' '[:lower:]')"

success() {
    local actual
    actual="$("$BASH" "$script" "${1:-ap-southeast-1}" 2> "$test_dir/err")"
    [[ "$actual" == "{\"thumbprint\":\"$expected\"}" ]] || {
        printf 'Unexpected thumbprint output: %s\n' "$actual" >&2
        exit 1
    }
}

reject() {
    if "$BASH" "$script" "$@" > "$test_dir/out" 2> "$test_dir/err"; then
        printf 'Invalid input unexpectedly produced a thumbprint.\n' >&2
        exit 1
    fi
    [[ ! -s "$test_dir/out" && -s "$test_dir/err" ]]
}

cat "$test_dir/leaf.pem" "$test_dir/intermediate.pem" > "$TEST_CHAIN"
success
cat "$test_dir/root.pem" >> "$TEST_CHAIN"
success
TEST_SERVER=s3.amazonaws.com success us-east-1
TEST_MODE=tls-failure reject ap-southeast-1
TEST_MODE=bad-fingerprint reject ap-southeast-1
TEST_MODE=fingerprint-failure reject ap-southeast-1
cat "$test_dir/leaf.pem" > "$TEST_CHAIN"
reject ap-southeast-1
cat "$test_dir/leaf.pem" "$test_dir/leaf.pem" > "$TEST_CHAIN"
reject ap-southeast-1
: > "$TEST_CHAIN"
reject ap-southeast-1
printf '%s\n' '-----BEGIN CERTIFICATE-----' invalid '-----END CERTIFICATE-----' > "$TEST_CHAIN"
cat "$test_dir/leaf.pem" "$TEST_CHAIN" > "$test_dir/invalid.pem"
cp "$test_dir/invalid.pem" "$TEST_CHAIN"
reject ap-southeast-1
reject
reject 'ap-southeast-1;echo invalid'
reject ap-southeast-1 extra
if PATH="$test_dir/empty" /bin/bash "$script" ap-southeast-1 > "$test_dir/out" 2> "$test_dir/err"; then
    printf 'Missing OpenSSL unexpectedly succeeded.\n' >&2
    exit 1
fi
[[ ! -s "$test_dir/out" ]]
grep 'Required command not found: openssl' "$test_dir/err" > /dev/null
printf 'Thumbprint CA selection and failure tests passed.\n'
