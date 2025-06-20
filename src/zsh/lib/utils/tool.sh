#!/usr/bin/env zsh

[[ -n "${__CNTC_UTILS_TOOL__}" ]] && return
readonly __CNTC_UTILS_TOOL__=1

is_el_in_array() {
    local el="$1"
    shift
    local arr=("$@")

    for item in "${arr[@]}"; do
        if [[ "$item" == "$el" ]]; then
            return 0  # Element found
        fi
    done

    return 1  # Element not found
}