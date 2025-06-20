#!/usr/bin/env zsh

[[ -n "${__CNTC_VAR__}" ]] && return
readonly __CNTC_VAR__=1

# ===================== BEFORE I18N INIT =====================

# _ti and _t command use this function to get the value of a key 
# in the loaded ini file. so, it cant use those command inside.
ini_loaded_get() {
    local value target key

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--target) target="$2"; shift 2 ;;
            -*) cntc_log -s "conf_var.ini_loaded_get" -d "Unknown option '$1'."; exit 1 ;;
            *) break ;;
        esac
    done

    [[ -z ${CNTC_SUPPORTED_INI_SUFFIX[(Ie)$target]} ]] && { 
        cntc_log -s "conf_file.ini_parse" -d "Invalid target '$target', must be one of: ${CNTC_SUPPORTED_INI_SUFFIX[@]}."; 
        exit 1; 
    }

    key="$*"
    [[ -z "$key" ]] && { cntc_log -s "conf_var.ini_loaded_get" -d "No key specified."; exit 1; }
    eval "value=\"\${CNTC_${target}[\"$key\"]}\""
    [[ -z "$value" ]] && { cntc_log -s "conf_var.ini_loaded_get" -d "Key '$key' not found in 'CNTC_${target}'."; exit 1; }
    echo "$value"
}

ini_loaded_clear() {
    local target
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--target) target="$2"; shift 2 ;;
            -*) cntc_log -s "conf_var.ini_loaded_clear" -d "Unknown option '$1'."; exit 1 ;;
            *) break ;;
        esac
    done
    [[ -z ${CNTC_SUPPORTED_INI_SUFFIX[(Ie)$target]} ]] && { 
        cntc_log -s "conf_file.ini_parse" -d "Invalid target '$target', must be one of: ${CNTC_SUPPORTED_INI_SUFFIX[@]}."; 
        exit 1; 
    }
    eval "declare -gA CNTC_$target"
}

ini_loaded_set() {
    local target key value

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--target) target="$2"; shift 2 ;;
            -*) cntc_log -s "conf_var.ini_loaded_set" -d "Unknown option '$1'."; exit 1 ;;
            *) break ;;
        esac
    done

    key=$1
    value=$2

    is_el_in_array $target ${CNTC_SUPPORTED_INI_SUFFIX[@]} || { 
        cntc_log -s "conf_file.ini_parse" -d "Invalid target '$target', must be one of: ${CNTC_SUPPORTED_INI_SUFFIX[@]}."; 
        exit 1; 
    }

    [[ -z "$key" ]] && { cntc_log -s "conf_var.ini_loaded_set" -d "No key specified."; exit 1; }
    
    eval "$(printf "CNTC_%s[%s]=$value\n" "$target" "$key")"
}

# ===================== AFTER I18N INIT =====================

ini_loaded_has() {
    local value target key

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--target) target="$2"; shift 2 ;;
            -*) cntc_log -s "conf_var.ini_loaded_has" -d "$(_t "debug.unknown_option")"; exit 1 ;;
            *) break ;;
        esac
    done

    [[ -z ${CNTC_SUPPORTED_INI_SUFFIX[(Ie)$target]} ]] && { 
        cntc_log -s "conf_var.ini_loaded_has" -d "$(_t "conf_debug.invalid_target" "$target" "$(printf "%s " "${CNTC_SUPPORTED_INI_SUFFIX[@]}")")";  
        exit 1; 
    }

    key="$*"
    [[ -z "$key" ]] && { cntc_log -s "conf_var.ini_loaded_has" -d "$(_t "conf_debug.key_need")"; exit 1; }
    eval "value=\"\${CNTC_${target}[\"$key\"]}\""
    [[ -n "$value" ]] && echo "true" || echo "false"
}