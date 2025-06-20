#!/usr/bin/env zsh

[[ -n "${__CNTC_CONF_INIT__}" ]] && return
readonly __CNTC_CONF_INIT__=1

_log_init() {
    [[ ! -f $CNTC_LOG_FILE ]] && {
        touch "$CNTC_LOG_FILE" 2>/dev/null || { 
            printf "[$BASE][$SCOPE]: Failed to create CNTC_LOG_FILE.\n" "conf_init.init" "$CNTC_LOG_FILE" >&2; 
            exit 1; 
        }
    }
    [[ ! -w $CNTC_LOG_FILE ]] && {
        printf "[$BASE][$SCOPE]: CNTC_LOG_FILE is not writable: %s\n" "$CNTC_LOG_FILE" >&2
        exit 1
    }
}

_config_init() {
    local value escaped_field
    local CNTC_CONFIG_DIR="$(dirname "$CNTC_CONFIG_FILE")"
    local default_prefix="CNTC_DEFAULT_"
    local default_fields=(
        "CORE_RETRY" 
        "CORE_TIMEOUT" 
        "ENCRYPT_ENABLE" 
        "ENCRYPT_ALGORITHM" 
        "TERMINAL_LANG" 
        "TERMINAL_COMPLEXITY"
    )

    [ ! -f "$CNTC_CONFIG_FILE" ] && {
        mkdir -p "$CNTC_CONFIG_DIR" || { cntc_log -s "conf_init._config_load" -d "Cannot create config folder: $CNTC_CONFIG_DIR."; exit 1; };
        touch "$CNTC_CONFIG_FILE" || { cntc_log -s "conf_init._config_load" -d "Cannot create config file: $CNTC_CONFIG_DIR."; exit 1; };
        cp "$CNTC_TEMPLATE_CONFIG_FILE" "$CNTC_CONFIG_FILE"
        # outside variable, so we can use it in the next step
        NEED_TIP="true"
    }

    ini_loaded_clear --target "CONFIG"

    for field in "${default_fields[@]}"; do
        escaped_field=$(echo "$field" | awk '{ f=tolower($0); gsub(/_/, ".", f); gsub(/["\$`\\]/, "\\\\&", f); print f }')
        eval "value=\$${default_prefix}${field}"
        ini_loaded_set --target "CONFIG" "$escaped_field" "$value"
    done

    ini_parse --target "CONFIG" --file $CNTC_CONFIG_FILE
}

_i18n_init() {
    local lang file
    local is_first="false"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--first) is_first=1; shift ;;
            *) break ;;
        esac
    done

    lang="$1"
    file="$CNTC_LOCALES_DIR/${lang}.conf"

    [[ ! -f "$file" ]] && {
        if [[ $is_first == 1 ]]; then
            cntc_log -s "init._i18n_load" -d "File not find: $lang_file."
            exit 1
        else
            cntc_log -s "init" -e "$(_ti "conf_init.lang_not_find" "$lang")"
            cntc_log -s "init" -e "$(_t "conf_init.lang_available")"
            ls "${CNTC_LOCALES_DIR}"/*.conf 2>/dev/null | \
                sed -e "s|${CNTC_LOCALES_DIR}/||" -e 's/\.conf$//' | \
                column -c $(tput cols) >&2
            echo >&2
            exit 1
        fi
    }

    ini_loaded_clear --target "TRANS";
    ini_parse --target "TRANS" --file $file;
    return 0;
}


conf_init() {
    local NEED_TIP="false"

    _log_init
    _config_init

    # DONT use $() to load _config_load, it will create a subshell
    _i18n_init --first "$(_c "terminal.lang")"

    $NEED_TIP && { cntc_log -s "init" -i "$(_t "conf_init.need_init")"; }

    # load available campus
    ini_campus_parse
}
