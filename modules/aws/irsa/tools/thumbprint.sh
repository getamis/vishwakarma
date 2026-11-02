#!/bin/bash
set -euo pipefail

# Return the highest intermediate CA's SHA-1 fingerprint as external-data JSON.
fail() {
    printf 'thumbprint: %s\n' "$1" >&2
    exit 1
}

[[ $# -eq 1 ]] || fail "Usage: thumbprint.sh AWS_REGION"
[[ "$1" =~ ^[a-z]{2}(-[a-z0-9]+)+-[0-9]+$ ]] || fail "Invalid AWS region."
for tool in openssl awk cut tr grep mktemp; do
    command -v "$tool" >/dev/null || fail "Required command not found: $tool"
done

if [[ "$1" == "us-east-1" ]]; then
    OIDC_SERVERNAME="s3.amazonaws.com"
else
    OIDC_SERVERNAME="s3-$1.amazonaws.com"
fi
readonly OIDC_SERVERNAME
work_dir="$(mktemp -d)"
readonly work_dir
cleanup() {
    rm -f "$work_dir"/*.pem
    rmdir "$work_dir"
}
trap cleanup EXIT

openssl s_client -connect "${OIDC_SERVERNAME}:443" -servername "$OIDC_SERVERNAME" \
    -showcerts -verify_return_error -verify_hostname "$OIDC_SERVERNAME" \
    < /dev/null > "$work_dir/chain.pem" ||
    fail "TLS verification failed for $OIDC_SERVERNAME."

count="$(awk -v directory="$work_dir" '
    /-----BEGIN CERTIFICATE-----/ { count++; file = directory "/" count ".pem" }
    file != "" { print > file }
    /-----END CERTIFICATE-----/ { close(file); file = "" }
    END { print count + 0 }
' "$work_dir/chain.pem")"

# A server may include its root; skip self-issued roots and never use the leaf.
certificate=""
for ((i=count; i>=2; i--)); do
    candidate="$work_dir/$i.pem"
    subject="$(openssl x509 -in "$candidate" -noout -subject -nameopt RFC2253)"
    issuer="$(openssl x509 -in "$candidate" -noout -issuer -nameopt RFC2253)"
    if [[ "${subject#subject=}" == "${issuer#issuer=}" ]]; then
        continue
    fi
    openssl x509 -in "$candidate" -noout -text | grep 'CA:TRUE' > /dev/null ||
        fail "Highest non-root certificate is not a CA."
    certificate="$candidate"
    break
done
[[ -n "$certificate" ]] || fail "No intermediate CA found in the TLS certificate chain."

thumbprint="$(openssl x509 -in "$certificate" -sha1 -noout -fingerprint |
    cut -d '=' -f 2 | tr -d ':' | tr '[:upper:]' '[:lower:]')"
[[ "$thumbprint" =~ ^[0-9a-f]{40}$ ]] || fail "Expected a 40-character hexadecimal CA thumbprint."
printf '{"thumbprint":"%s"}\n' "$thumbprint"