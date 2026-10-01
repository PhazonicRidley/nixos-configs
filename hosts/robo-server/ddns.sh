#!/usr/bin/env bash

BASE_DOMAIN="phazonicridley.com"

API_KEY=$(awk -F'=' '{print $2}' /var/lib/secrets/dreamhost-acme-env)

CURRENT_IP=$(ip -6 addr show enp39s0 \
  | grep 'inet6 2' \
  | grep -v 'temporary' \
  | awk '{print $2}' \
  | cut -d/ -f1 \
  | head -1 || true)

if [ -z "$CURRENT_IP" ]; then
  echo "No stable GUA found on enp39s0" >&2
  exit 1
fi

DNS_RECORDS=$(curl -s \
  "https://api.dreamhost.com/?key=${API_KEY}&cmd=dns-list_records&format=json")

if ! echo "$DNS_RECORDS" | jq -e '.data' > /dev/null 2>&1; then
  echo "Dreamhost API returned unexpected response: $DNS_RECORDS" >&2
  exit 0
fi

update_record() {
  local domain="$1"

  OLD_IP=$(echo "$DNS_RECORDS" \
    | jq -r --arg domain "$domain" \
      '.data[] | select(.type=="AAAA" and .record==$domain) | .value')

  [ "$CURRENT_IP" = "$OLD_IP" ] && return 0

  [ -n "$OLD_IP" ] && curl -s \
    "https://api.dreamhost.com/?key=${API_KEY}&cmd=dns-remove_record&record=${domain}&type=AAAA&value=${OLD_IP}"

  curl -s \
    "https://api.dreamhost.com/?key=${API_KEY}&cmd=dns-add_record&record=${domain}&type=AAAA&value=${CURRENT_IP}"
}

update_record "$BASE_DOMAIN"
for subdomain in "$@"; do
  update_record "${subdomain}.${BASE_DOMAIN}"
done
