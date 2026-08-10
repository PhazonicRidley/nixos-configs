#!/usr/bin/env bash

API_KEY=$(cat /var/lib/secrets/dreamhost-acme-env | awk -F'=' '{print $2}')

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

update_record() {
  local domain="$1"

  OLD_IP=$(curl -s \
    "https://api.dreamhost.com/?key=${API_KEY}&cmd=dns-list_records&format=json" \
    | jq -r --arg domain "$domain" \
      '.data[] | select(.type=="AAAA" and .record==$domain) | .value')

  [ "$CURRENT_IP" = "$OLD_IP" ] && return 0

  [ -n "$OLD_IP" ] && curl -s \
    "https://api.dreamhost.com/?key=${API_KEY}&cmd=dns-remove_record&record=${domain}&type=AAAA&value=${OLD_IP}"

  curl -s \
    "https://api.dreamhost.com/?key=${API_KEY}&cmd=dns-add_record&record=${domain}&type=AAAA&value=${CURRENT_IP}"
}

update_record "phazonicridley.com"
update_record "*.phazonicridley.com"
