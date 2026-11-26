# Keep AAAA records for phazonicridley.com (and any subdomains given as args)
# pointed at this host's stable global IPv6 address, via DreamHost's v1 API.
#
# (The DreamHost API client from modules/nixos/dreamhost/api.sh is prepended at
# build time and provides dh_list/dh_send/dh_expect; it reads the key from
# $DREAMHOST_API_KEY_FILE.)

ZONE="phazonicridley.com"
IFACE="enp39s0"

CURRENT_IP=$(ip -6 addr show "$IFACE" \
  | grep 'inet6 2' \
  | grep -v 'temporary' \
  | awk '{print $2}' \
  | cut -d/ -f1 \
  | head -1 || true)

if [ -z "$CURRENT_IP" ]; then
  echo "No stable GUA found on ${IFACE}" >&2
  exit 1
fi

# update_record NAME -- NAME is relative to $ZONE ("@" for the apex)
update_record() {
  local name="$1" old_ip body

  dh_list "$ZONE" "$name" "AAAA"
  dh_expect 200
  old_ip=$(jq -r '.data[0].value // empty' "$DH_BODY_FILE")

  if [ "$old_ip" = "$CURRENT_IP" ]; then
    return 0
  fi

  if [ -n "$old_ip" ]; then
    body=$(jq -cn --arg name "$name" --arg old "$old_ip" --arg new "$CURRENT_IP" \
      '{currentRecord: {name: $name, type: "AAAA", value: $old},
        newRecord: {name: $name, type: "AAAA", fields: {ip: $new}}}')
    dh_send PUT "$ZONE" "$body"
  else
    body=$(jq -cn --arg name "$name" --arg new "$CURRENT_IP" \
      '{records: [{name: $name, type: "AAAA", fields: {ip: $new}}]}')
    dh_send POST "$ZONE" "$body"
  fi
  dh_expect 200 201 202
  echo "AAAA ${name}.${ZONE}: ${old_ip:-<none>} -> ${CURRENT_IP} (HTTP ${DH_STATUS})"
}

update_record "@"
for subdomain in "$@"; do
  update_record "$subdomain"
done
