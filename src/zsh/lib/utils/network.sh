#!/usr/bin/env zsh

[[ -n "${__CNTC_NETWORK__}" ]] && return
readonly __CNTC_NETWORK__=1

get_ip() {
    OS_TYPE="$(uname)"
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        IP=$(ipconfig getifaddr en0 2>/dev/null)
        [[ -z "$IP" ]] && IP=$(ipconfig getifaddr en1 2>/dev/null)
    elif [[ "$OS_TYPE" == "Linux" ]]; then
        if command -v hostname >/dev/null 2>&1; then
            IP=$(hostname -I | awk '{print $1}')
        elif command -v ip >/dev/null 2>&1; then
            IP=$(ip addr show | awk '/inet / && $2 !~ /^127/ {print $2}' | cut -d/ -f1 | head -n 1)
        fi
    else
        cntc_log -s "utils_network.get_ip" -d "$(_ti "utils.unsupported_os" "$OS_TYPE")"
        exit 1
    fi
    if [[ -n "$IP" ]]; then
        echo "$IP"
    else
        cntc_log -s "utils_network.get_ip" -e "$(_ti "utils.no_ip_detected")"
    fi
}

check_internet() {
  TARGET="8.8.8.8"
  if ping -c 1 -W 2 "$TARGET" >/dev/null 2>&1; then
    echo "true"
  else
    echo "false"
  fi
}