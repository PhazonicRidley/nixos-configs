# Minimal client for DreamHost's v1 API (https://developers.dreamhost.com/).
# Sourced (concatenated) ahead of the scripts that use it, not run directly.
#
# Auth: a Bearer token read from $DREAMHOST_API_KEY_FILE. The header is fed to
# curl through a process substitution so the key never shows up in argv / `ps`.
#
#   dh_request METHOD ZONE [extra curl args...]
#     Sets $DH_STATUS to the HTTP status and leaves the response body in $DH_BODY_FILE.

DH_API="https://api.dreamhost.com/v1/dns"
DH_KEY="$(<"${DREAMHOST_API_KEY_FILE:?DREAMHOST_API_KEY_FILE not set}")"
DH_BODY_FILE="$(mktemp)"
DH_STATUS=""
trap 'rm -f "$DH_BODY_FILE"' EXIT

dh_request() {
  local method="$1" zone="$2"
  shift 2
  DH_STATUS=$(curl -sS --max-time 60 -o "$DH_BODY_FILE" -w '%{http_code}' \
    -X "$method" \
    -H @<(printf 'Authorization: Bearer %s\n' "$DH_KEY") \
    -H 'Accept: application/json' \
    "$@" "${DH_API}/${zone}")
}

# Fail loudly (with DreamHost's error body) unless the last request returned one of the given statuses.
dh_expect() {
  local s
  for s in "$@"; do
    [ "$DH_STATUS" = "$s" ] && return 0
  done
  echo "DreamHost API returned HTTP ${DH_STATUS} (expected $*): $(cat "$DH_BODY_FILE")" >&2
  exit 1
}

# dh_send METHOD ZONE JSON -- request with a JSON body
dh_send() {
  dh_request "$1" "$2" -H 'Content-Type: application/json' --data-binary "$3"
}

# dh_list ZONE NAME TYPE -- list records filtered by relative name and type
dh_list() {
  dh_request GET "$1" -G --data-urlencode "name=$2" --data-urlencode "type=$3"
}
