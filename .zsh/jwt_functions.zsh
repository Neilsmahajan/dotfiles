# =============================================================================
# JWT & Keychain Shell Functions
# Sourced from ~/.zshrc:  source ~/.zsh/jwt_functions.zsh
# Managed via dotfiles repo (~/dotfiles) -- symlinked by `stow .`
#
# Dependencies: jq, curl, security (macOS Keychain CLI)
#
# --- First-time setup --------------------------------------------------------
#
# 1. For M2M (federation) tokens, store client credentials in macOS Keychain:
#
#      keystore bxp_federation_staging_client_id     "YOUR_CLIENT_ID"
#      keystore bxp_federation_staging_client_secret "YOUR_CLIENT_SECRET"
#      keystore bxp_federation_dev_client_id         "YOUR_CLIENT_ID"
#      keystore bxp_federation_dev_client_secret     "YOUR_CLIENT_SECRET"
#
#    Use `keylist` to verify they were saved, or `keyget <name> -print` to
#    read one back. You can store any arbitrary secret with `keystore`.
#
# 2. User tokens (jwt_auth0_user, jwt_auth0_user_dev) prompt for your Auth0
#    password at runtime -- no keychain setup needed for those.
#
# 3. Tokens are cached in ~/.jwt_cache/ and reused until they expire (checked
#    via the JWT `exp` claim). Run `jwt_cache_clear` to wipe the cache.
#
# --- Quick reference ---------------------------------------------------------
#
#   Keychain:
#     keylist                          List stored secrets
#     keystore <name> <value>          Store a secret
#     keyget <name> [-print]           Retrieve (copies to clipboard, or -print)
#     keydelete <name>                 Delete a secret
#
#   User tokens (password grant -- prompts for password):
#     jwt_auth0_user [scopes]          Staging token for default email
#     jwt_auth0_user_dev [scopes]      Dev token for default email
#     jwt_auth0_u_staging <email> [s]  Staging token for arbitrary user
#     jwt_auth0_u_dev <email> [scopes] Dev token for arbitrary user
#
#   M2M tokens (client_credentials -- uses keychain secrets):
#     jwt_auth0_federation             Staging federation M2M token
#     jwt_auth0_federation_dev         Dev federation M2M token
#
#   Utilities:
#     jwt_decode <token>               Decode JWT payload to JSON
#     jwt_info <token>                 Decoded payload + expiration info
#     jwt_expired <token>              Print "valid" or "expired"
#     jwt_cache_clear                  Wipe all cached tokens
#
# =============================================================================

# -- Configuration ------------------------------------------------------------

JWT_CACHE_DIR="${HOME}/.jwt_cache"
# JWT_DEFAULT_EMAIL="neil.mahajan@netapp.com"
JWT_DEFAULT_EMAIL="federationtest1@netapp-test.com"
JWT_DEFAULT_SCOPES="openid profile support:gtc data-lake:support cc:support data-lake:automation cc:federation-support"

# Auth0 environment config (associative arrays)
typeset -A JWT_AUTH0_URLS
JWT_AUTH0_URLS=(
    staging "https://staging-netapp-cloud-account.auth0.com/oauth/token"
    dev     "https://dev-netapp-cloud-account.auth0.com/oauth/token"
)

typeset -A JWT_AUTH0_CLIENT_IDS
JWT_AUTH0_CLIENT_IDS=(
    staging "VcPXCf6rPTPQsyS2oIt6SP5ZSgnUHI3S"
    dev     "eASY8T987sCSZ4gy6qP18y0voYvRegJa"
)

JWT_AUTH0_AUDIENCE="https://api.cloud.netapp.com"

# =============================================================================
# Keychain Functions (macOS security CLI wrappers)
# All entries are stored with a "key_" prefix in Keychain.
# =============================================================================

function keylist() {
    security dump-keychain \
        | awk -F'=' '/0x00000007/ { print $2 }' \
        | grep 'key_' \
        | tr -d '"' \
        | sed 's/^key_//' \
        | sort
}

function keystore() {
    local name="$1"
    local pw="$2"
    if [[ -z "$name" || -z "$pw" ]]; then
        echo "Usage: keystore <name> <password>"
        return 1
    fi
    security add-generic-password -a "$LOGNAME" -U -s "key_${name}" -w "$pw"
}

function keyget() {
    local name="$1"
    local option="$2"
    if [[ -z "$name" ]]; then
        echo "Usage: keyget <name> [-print]"
        return 1
    fi
    local pw
    pw="$(security find-generic-password -a "$LOGNAME" -s "key_${name}" -w 2>/dev/null)"
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Key 'key_${name}' not found in keychain" >&2
        return 1
    fi
    if [[ "$option" == "-print" ]]; then
        echo "$pw"
    else
        echo -n "$pw" | pbcopy
        echo "Copied to clipboard."
    fi
}

function keydelete() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Usage: keydelete <name>"
        return 1
    fi
    if read -q "REPLY?Delete key '${name}' from keychain? [y/N] "; then
        echo
        security delete-generic-password -a "$LOGNAME" -s "key_${name}"
    else
        echo
        echo "Cancelled."
    fi
}

# =============================================================================
# JWT Cache Functions
# Tokens are cached as flat files in $JWT_CACHE_DIR, keyed by name.
# On retrieval, the JWT exp claim is checked -- expired tokens are ignored.
# =============================================================================

function _jwt_cache_init() {
    if [[ ! -d "$JWT_CACHE_DIR" ]]; then
        mkdir -p "$JWT_CACHE_DIR"
    fi
}

function _jwt_cache_store() {
    local key="$1"
    local token="$2"
    _jwt_cache_init
    echo -n "$token" > "${JWT_CACHE_DIR}/${key}"
}

function _jwt_cache_load() {
    local key="$1"
    local cache_file="${JWT_CACHE_DIR}/${key}"
    _jwt_cache_init
    if [[ -f "$cache_file" ]]; then
        cat "$cache_file"
    fi
}

function jwt_cache_get() {
    local key="$1"
    local token
    token="$(_jwt_cache_load "$key")"
    if [[ -z "$token" ]]; then
        return
    fi
    if [[ "$(jwt_expired "$token")" == "valid" ]]; then
        echo "$token"
    fi
}

function jwt_cache_clear() {
    if [[ -d "$JWT_CACHE_DIR" ]]; then
        rm -f "${JWT_CACHE_DIR}"/*
        echo "JWT cache cleared."
    else
        echo "No cache directory found."
    fi
}

# =============================================================================
# JWT Utility Functions
# =============================================================================

# Decode a JWT and pretty-print the payload as JSON
function jwt_decode() {
    local token="${1:-$(cat -)}"
    if [[ -z "$token" ]]; then
        echo "Usage: jwt_decode <token>  (or pipe a token in)"
        return 1
    fi
    echo "$token" | jq -R 'split(".") | .[1] | @base64d | fromjson'
}

# Check if a JWT is expired. Prints "expired" or "valid".
function jwt_expired() {
    local token="$1"
    if [[ -z "$token" ]]; then
        echo "Usage: jwt_expired <token>"
        return 1
    fi
    local exp
    exp="$(jwt_decode "$token" | jq -r '.exp')"
    local now
    now="$(date +%s)"
    if [[ "$exp" -lt "$now" ]]; then
        echo "expired"
    else
        echo "valid"
    fi
}

# Show decoded info about a JWT: expiration time, time remaining, and claims
function jwt_info() {
    local token="${1:-$(cat -)}"
    if [[ -z "$token" ]]; then
        echo "Usage: jwt_info <token>  (or pipe a token in)"
        return 1
    fi
    local payload
    payload="$(jwt_decode "$token")"
    local exp
    exp="$(echo "$payload" | jq -r '.exp')"
    local now
    now="$(date +%s)"
    local remaining=$(( exp - now ))

    echo "--- JWT Info ---"
    if [[ $remaining -gt 0 ]]; then
        echo "Status:  valid (expires in $(( remaining / 60 ))m $(( remaining % 60 ))s)"
    else
        echo "Status:  EXPIRED ($(( -remaining / 60 ))m ago)"
    fi
    echo "Expires: $(date -r "$exp" 2>/dev/null || date -d "@$exp" 2>/dev/null)"
    echo "--- Payload ---"
    echo "$payload" | jq .
}

# =============================================================================
# Auth0 Token Functions
# =============================================================================

# Generic user (resource owner password grant) token fetcher.
# Usage: _jwt_auth0_user_token <env> <email> [scopes]
#   env:    "staging" or "dev"
#   email:  Auth0 username
#   scopes: space-separated scope string (default: $JWT_DEFAULT_SCOPES)
function _jwt_auth0_user_token() {
    local env="$1"
    local email="$2"
    local scope="${3:-$JWT_DEFAULT_SCOPES}"

    if [[ -z "$env" || -z "$email" ]]; then
        echo "Usage: _jwt_auth0_user_token <staging|dev> <email> [scopes]"
        return 1
    fi

    local url="${JWT_AUTH0_URLS[$env]}"
    local client_id="${JWT_AUTH0_CLIENT_IDS[$env]}"
    if [[ -z "$url" || -z "$client_id" ]]; then
        echo "ERROR: Unknown environment '$env'. Use 'staging' or 'dev'."
        return 1
    fi

    # Build a cache key from email + env + scopes
    local email_sanitized="${email//[.@]/-}"
    local scope_sanitized="${scope//[ :]/-}"
    local cache_key="${email_sanitized}_${env}_${scope_sanitized}"

    if [[ "$scope" == "default" ]]; then
        scope=""
    fi

    # Try cache first
    local token
    token="$(jwt_cache_get "$cache_key")"
    if [[ -n "$token" ]]; then
        echo "$token"
        return
    fi

    # Prompt for password
    local password
    echo -n "Password for ${email} (${env}): " >&2
    read -s password
    echo >&2

    if [[ -z "$password" ]]; then
        echo "ERROR: No password provided." >&2
        return 1
    fi

    local resp
    resp="$(curl -sS -X POST -H "Content-Type: application/json" "$url" -d "{
        \"username\": \"${email}\",
        \"scope\": \"${scope}\",
        \"audience\": \"${JWT_AUTH0_AUDIENCE}\",
        \"client_id\": \"${client_id}\",
        \"grant_type\": \"password\",
        \"password\": \"${password}\"
    }")"

    token="$(echo "$resp" | jq -r '.access_token')"
    if [[ "$token" == "null" || -z "$token" ]]; then
        echo "ERROR: $(echo "$resp" | jq -r '.error_description // .error // "Unknown error"')" >&2
        return 1
    fi

    _jwt_cache_store "$cache_key" "$token"
    echo "$token"
}

# Get my personal user access token from staging Auth0
function jwt_auth0_user() {
    _jwt_auth0_user_token "staging" "$JWT_DEFAULT_EMAIL" "$1"
}

# Get my personal user access token from dev Auth0
function jwt_auth0_user_dev() {
    _jwt_auth0_user_token "dev" "$JWT_DEFAULT_EMAIL" "$1"
}

# Get a token for an arbitrary user on dev Auth0
# Usage: jwt_auth0_u_dev <email> [scopes]
function jwt_auth0_u_dev() {
    local email="$1"
    if [[ -z "$email" ]]; then
        echo "Usage: jwt_auth0_u_dev <email> [scopes]"
        return 1
    fi
    _jwt_auth0_user_token "dev" "$email" "${2:-openid profile}"
}

# Get a token for an arbitrary user on staging Auth0
# Usage: jwt_auth0_u_staging <email> [scopes]
function jwt_auth0_u_staging() {
    local email="$1"
    if [[ -z "$email" ]]; then
        echo "Usage: jwt_auth0_u_staging <email> [scopes]"
        return 1
    fi
    _jwt_auth0_user_token "staging" "$email" "${2:-openid profile}"
}

# Generic M2M (client_credentials) token fetcher.
# Usage: _jwt_auth0_m2m_token <env> <cache_key> <client_id_keychain> <client_secret_keychain>
function _jwt_auth0_m2m_token() {
    local env="$1"
    local cache_key="$2"
    local client_id_key="$3"
    local client_secret_key="$4"

    if [[ -z "$env" || -z "$cache_key" || -z "$client_id_key" || -z "$client_secret_key" ]]; then
        echo "Usage: _jwt_auth0_m2m_token <staging|dev> <cache_key> <client_id_keychain_key> <client_secret_keychain_key>"
        return 1
    fi

    local url="${JWT_AUTH0_URLS[$env]}"
    if [[ -z "$url" ]]; then
        echo "ERROR: Unknown environment '$env'." >&2
        return 1
    fi

    # Try cache first
    local token
    token="$(jwt_cache_get "$cache_key")"
    if [[ -n "$token" ]]; then
        echo "$token"
        return
    fi

    local client_id
    client_id="$(keyget "$client_id_key" -print)"
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Could not retrieve client ID from keychain key '${client_id_key}'." >&2
        return 1
    fi

    local client_secret
    client_secret="$(keyget "$client_secret_key" -print)"
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Could not retrieve client secret from keychain key '${client_secret_key}'." >&2
        return 1
    fi

    local resp
    resp="$(curl -sS -X POST -H "Content-Type: application/json" "$url" -d "{
        \"audience\": \"${JWT_AUTH0_AUDIENCE}\",
        \"client_id\": \"${client_id}\",
        \"grant_type\": \"client_credentials\",
        \"client_secret\": \"${client_secret}\"
    }")"

    token="$(echo "$resp" | jq -r '.access_token')"
    if [[ "$token" == "null" || -z "$token" ]]; then
        echo "ERROR: $(echo "$resp" | jq -r '.error_description // .error // "Unknown error"')" >&2
        return 1
    fi

    _jwt_cache_store "$cache_key" "$token"
    echo "$token"
}

# Get Federation service M2M token from staging Auth0
# Requires keychain entries: bxp_federation_staging_client_id, bxp_federation_staging_client_secret
function jwt_auth0_federation() {
    _jwt_auth0_m2m_token "staging" "federation_staging_m2m" \
        "bxp_federation_staging_client_id" "bxp_federation_staging_client_secret"
}

# Get Federation service M2M token from dev Auth0
# Requires keychain entries: bxp_federation_dev_client_id, bxp_federation_dev_client_secret
function jwt_auth0_federation_dev() {
    _jwt_auth0_m2m_token "dev" "federation_dev_m2m" \
        "bxp_federation_dev_client_id" "bxp_federation_dev_client_secret"
}
