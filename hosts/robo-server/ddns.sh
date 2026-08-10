#!/usr/bin/env bash

DOMAIN="phazonicridley.com"

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

OLD_IP=$(curl -s \
  "https://api.dreamhost.com/?key=${API_KEY}&cmd=dns-list_records&format=json" \
  | jq -r --arg domain "$DOMAIN" \
    '.data[] | select(.type=="AAAA" and .record==$domain) | .value')

[ "$CURRENT_IP" = "$OLD_IP" ] && exit 0

[ -n "$OLD_IP" ] && curl -s \
  "https://api.dreamhost.com/?key=${API_KEY}&cmd=dns-remove_record&record=${DOMAIN}&type=AAAA&value=${OLD_IP}"

curl -s \
  "https://api.dreamhost.com/?key=${API_KEY}&cmd=dns-add_record&record=${DOMAIN}&type=AAAA&value=${CURRENT_IP}"
