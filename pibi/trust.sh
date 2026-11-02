#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 || $# -ne 1 ]]; then
    echo "Usage: sudo $0 cosign.pub" >&2
    exit 1
fi

if ! grep -qx -- '-----BEGIN PUBLIC KEY-----' "$1"; then
    echo "Expected a PEM public key" >&2
    exit 1
fi
openssl pkey -pubin -in "$1" -noout

image=ghcr.io/pixelcmtd/pibi
key_path=/etc/pki/containers/pibi.pub
policy=/etc/containers/policy.json
pending=$(mktemp /etc/containers/.pibi-policy.XXXXXX)
trap 'rm -f "$pending"' EXIT

jq --arg image "$image" --arg key "$key_path" '
    if (.default | type) != "array" then error("Invalid container policy") else . end
    | .transports.docker |= ((. // {}) | with_entries(select(
        .key != $image
        and (.key | startswith($image + ":") | not)
        and (.key | startswith($image + "@") | not)
    )))
    | .transports.docker[$image] = [{
        type: "sigstoreSigned",
        keyPath: $key,
        signedIdentity: {type: "matchRepository"}
    }]
' "$policy" > "$pending"

install -d -m 0755 /etc/pki/containers
openssl pkey -pubin -in "$1" -pubout -out "$key_path"
chmod 0644 "$key_path"
install -d -m 0755 /etc/containers/registries.d
cat > /etc/containers/registries.d/pibi.yaml <<EOF
docker:
  $image:
    use-sigstore-attachments: true
EOF
chmod 0644 /etc/containers/registries.d/pibi.yaml

chmod 0644 "$pending"
mv -f "$pending" "$policy"
trap - EXIT
