# lego `exec` DNS provider hook for DreamHost's v1 API.
# lego calls it as:  <present|cleanup> <fqdn> <txt-value>
# e.g.               present _acme-challenge.int.phazonicridley.com. <value>
#
# (api.sh is prepended at build time and provides dh_request/dh_send/dh_list/dh_expect.)

action="${1:?usage: present|cleanup <fqdn> <value>}"
fqdn="${2:?missing fqdn}"
value="${3:?missing value}"
fqdn="${fqdn%.}"

# Find the DreamHost zone that holds $fqdn by walking up its labels
# (_acme-challenge.int.example.com -> int.example.com -> example.com).
# Non-zone names may come back as 400/403/404; auth, rate-limit and server errors abort.
zone=""
last_error=""
candidate="${fqdn#*.}"
while [[ "$candidate" == *.* ]]; do
  dh_list "$candidate" "@" "NS"
  case "$DH_STATUS" in
    200)
      zone="$candidate"
      break
      ;;
    400 | 403 | 404)
      last_error="${candidate}: HTTP ${DH_STATUS} $(cat "$DH_BODY_FILE")"
      candidate="${candidate#*.}"
      ;;
    *) dh_expect 200 ;;
  esac
done
if [ -z "$zone" ]; then
  echo "No DreamHost zone found for ${fqdn} (does the key have DNS access?). Last response: ${last_error}" >&2
  exit 1
fi

# Record name relative to the zone
name="${fqdn%."$zone"}"
[ "$name" = "$fqdn" ] && name="@"

case "$action" in
  present)
    body=$(jq -cn --arg name "$name" --arg content "$value" \
      '{records: [{name: $name, type: "TXT", fields: {content: $content}}]}')
    dh_send POST "$zone" "$body"
    dh_expect 200 201 202
    echo "Requested TXT ${name}.${zone} (HTTP ${DH_STATUS})"
    ;;

  cleanup)
    # DELETE needs the record's exact canonical value as GET returns it, so look it up first.
    dh_list "$zone" "$name" "TXT"
    dh_expect 200
    mapfile -t existing < <(jq -r --arg v "$value" \
      '.data[] | select(.fields.content == $v or .value == $v or .value == ("\"" + $v + "\"")) | .value' \
      "$DH_BODY_FILE")

    if [ "${#existing[@]}" -eq 0 ]; then
      echo "No TXT ${name}.${zone} with our value found; nothing to clean up"
      exit 0
    fi

    for v in "${existing[@]}"; do
      body=$(jq -cn --arg name "$name" --arg v "$v" '{record: {name: $name, type: "TXT", value: $v}}')
      dh_send DELETE "$zone" "$body"
      dh_expect 200 202 204 404
      echo "Requested deletion of TXT ${name}.${zone} (HTTP ${DH_STATUS})"
    done
    ;;

  *)
    echo "Unknown action: ${action}" >&2
    exit 1
    ;;
esac
