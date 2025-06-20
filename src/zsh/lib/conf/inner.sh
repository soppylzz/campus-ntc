#!/usr/bin/env zsh

[[ -n "${__CNTC_INNER__}" ]] && return
readonly __CNTC_INNER__=1

# ===================== BEFORE I18N INIT =====================

_t() {
    local translation key="$1"
    translation=$(ini_loaded_get -t "TRANS" "$key")
    [[ -z "$translation" ]] && translation="$key"
    echo "$translation"
}

_ti() {
    local translation key="$1"; shift;
    local fill=("$@")
    translation=$(ini_loaded_get -t "TRANS" "$key")
    [[ -z "$translation" ]] && translation="$key"
    printf $translation "${fill[@]}"
}

# this function is used to get the config value from the loaded ini file.
# it will be used in i18n init, so it can't use _t or _ti.
_c() {
    local key config
    local bool_check="false"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -bc|--bool-check) bool_check="true"; shift ;;
            -*) cntc_log -d "Unknown option '$1'."; exit 1 ;;
            *) break ;;
        esac
    done

    key="$*"    # key is compressed key, like: core.retry
    config=$(ini_loaded_get -t "CONFIG" "$key")

    if $bool_check; then
        case $config in
            true|True|false|False) ;;
            *) cntc_log -s "conf_inner._c" -d "$(_ti "conf_debug.bool_check_tip" "$key")"; exit 1 ;;
        esac
    fi
    echo "$config"
}

# ===================== AFTER I18N INIT =====================

_cs() {
    local key value section

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--section) section="$2"; shift 2 ;;
            -*) cntc_log -s "conf_inner._cs" -d "$(_t "debug.unknown_option")"; exit 1 ;;
            *) break ;;
        esac
    done

    key="$1"  # key is raw key, like: retry
    value="$2"

    [[ ! -f "$CNTC_CONFIG_FILE" ]] && { 
        cntc_log -s "conf_inner._cs" -d "$(_ti "conf_debug.config_need" "$CNTC_CONFIG_FILE")"; exit 1;}
    [[ -z "$key" || -z "$value" ]] && { 
        cntc_log -s "conf_inner._cs" -d "$(_t "conf_debug.cs_tip")"; exit 1;}
    ini_update_item -f "$CNTC_CONFIG_FILE" -s "$section" $key $value || {
        cntc_log -s "conf_inner._cs" -d "$(_ti "conf_debug.cs_failed" "$section" "$key" "$value" )"; exit 1;}
    return 0;
}

_cd() {
    local key section

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--section) section="$2"; shift 2 ;;
            -*) cntc_log -s "conf_inner._cd" -d "$(_t "debug.unknown_option")"; exit 1 ;;
            *) break ;;
        esac
    done

    [[ ! -f "$CNTC_CONFIG_FILE" ]] && {
        cntc_log -s "conf_inner._cd" -d "$(_ti "conf_debug.config_need" "$CNTC_CONFIG_FILE")"; exit 1;}
    [[ -z "$section" ]] && {
        cntc_log -s "conf_inner._cd" -d "$(_t "conf_debug.cd_tip")"; exit 1;}

    key="$*"
    if [[ -z "$key" ]];then
        ini_delete_section -f "$CNTC_CONFIG_FILE" -s "$section" || {
            cntc_log -s "conf_inner._cd" -d "$(_ti "conf_debug.cd_failed" "$section")"; exit 1;
        }
    else
        ini_delete_item -f "$CNTC_CONFIG_FILE" -s "$section" "$key" || {
            cntc_log -s "conf_inner._cd" -d "$(_ti "conf_debug.cd_failed" "$section.$key")"; exit 1;
        }
    fi
    return 0
}

_ch() {
    echo "$(ini_loaded_has --target "CONFIG" "$1")"
}