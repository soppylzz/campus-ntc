#!/usr/bin/env zsh

[[ -n "${__CNTC_CONFIG_COMMAND__}" ]] && return
readonly __CNTC_CONFIG_COMMAND__=1

CNTC_COMMAND_CURRENT_DIR="${${${(%):-%x}:A:h}:h}"
source "$CNTC_COMMAND_CURRENT_DIR/lib/init.sh"

configure() {
    local rest
    local is_error="false" is_help="false"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) is_help="true"; shift; break ;;
            *) is_error="true"; break ;;
        esac
    done

    rest="$*"
    [[ -n "$rest" ]] && is_error="true"

    $is_error && {
        cntc_log -s "cntc configure" -w "$(_ti "debug.command_error" "$(printf "%s " "$@")" "cntc configure --help")\n" >&2;
        _configure_help
        exit 1
    }
    $is_help && {
        _configure_help
        return 0
    }
    
    cli_logo

    local complexity="$(_c "terminal.complexity")"

    cli_divider 50

    local conf_lang=$(cli_options --border \
                                    --intro "$(_t "config.lang_intro")" \
                                    --end "$(_t "config.lang_end")" \
                                    --header "$(_t "config.lang_header")" \
                                    --footer "$(_t "config.lang_footer")" \
                                    "${CNTC_SUPPORTED_LOCALES[@]}")

    local conf_complexity=$(cli_yn --line --border \
                              --intro "$(_t "config.comp_intro")" \
                              --yes "$(_t "config.comp_yes")" \
                              --no "$(_t "config.comp_no")" \
                              --header "$(_t "config.comp_header")" \
                              --footer "$(_t "config.comp_footer")" \
                              )

    local conf_encrypt=$(cli_yn --line --border \
                              --intro "$(_t "config.encrypt_intro")" \
                              --yes "$(_t "config.encrypt_yes")" \
                              --no "$(_t "config.encrypt_no")" \
                              --header "$(_t "config.encrypt_header")" \
                              --footer "$(_t "config.encrypt_footer")" \
                              )

    if [[ $conf_encrypt ]];then
        local conf_alg=$(cli_options --border \
                                --intro "$(_t "config.lang_intro")" \
                                --end "$(_t "config.lang_end")" \
                                --header "$(_t "config.lang_header")" \
                                --footer "$(_t "config.lang_footer")" \
                                "${CNTC_SUPPORTED_ALGORITHMS[@]}")
    fi

    local conf_retry=$(cli_input --border \
                            --intro "$(_t "config.retry_intro")" \
                            --end "$(_t "config.retry_end")" \
                            --header "$(_t "config.retry_header")" \
                            --footer "$(_t "config.retry_footer")")
    
    local conf_timeout=$(cli_input --border \
                            --intro "$(_t "config.timeout_intro")" \
                            --end "$(_t "config.timeout_end")" \
                            --header "$(_t "config.timeout_header")" \
                            --footer "$(_t "config.timeout_footer")")

    cli_divider 50

    local confirm=$(cli_yn --intro "$(_t "config.confirm_intro")" \
                              --yes "$(_t "config.confirm_yes")" \
                              --no "$(_t "config.confirm_no")")

    # real update
    if $confirm; then
        _cs --section "terminal" "lang" "$conf_lang"
        _cs --section "terminal" "complexity" "$conf_complexity"
        _cs --section "encrypt" "enable" "$conf_encrypt"
        $conf_encrypt && _cs --section "encrypt" "algorithm" "$conf_alg"
        _cs --section "core" "retry" "$conf_retry"
        _cs --section "core" "timeout" "$conf_timeout"

        if $complexity; then
            printf "\n" >&2
            _centered "$(_t "config.confirm_finish")"
        else
            printf "$(_t "config.confirm_finish")\n" >&2
        fi
    fi
}

config() {
    local is_error="false" is_help="false"
    local conf_timeout conf_retry conf_encrypt conf_alg conf_complexity conf_lang

    local all="$@"
    [[ -z "$all" ]] && is_error="true"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--lang) conf_lang=$2; shift 2; break ;;
            -c|--complexity) conf_complexity=$2; shift 2; break ;;
            -e|--encrypt) conf_encrypt=$2; shift 2; break ;;
            -a|--alg) conf_alg=$2; shift 2; break ;;
            -r|--retry) conf_retry=$2; shift 2; break ;;
            -t|--timeout) conf_timeout=$2; shift 2; break ;;
            -h|--help) is_help="true"; shift; break ;;
            *) is_error="true"; break ;;
        esac
    done

    local rest="$*"
    [[ -n "$rest" ]] && is_error="true"
    
    [[ -z ${CNTC_SUPPORTED_LOCALES[(Ie)$conf_lang]} ]] && is_error="true"
    [[ -z ${CNTC_SUPPORTED_ALGORITHMS[(Ie)$conf_alg]} ]] && is_error="true"
    $is_error && {
        cntc_log -s "cntc config" -w "$(_ti "debug.command_error" "$(printf "%s " "$@")" "cntc config --help")\n" >&2;
        _config_help
        exit 1
    }

    $is_help && {
        _config_help
        return 0
    }

    [[ -n "$conf_lang" ]] && _cs --section "terminal" "lang" "$conf_lang"
    [[ -n "$conf_complexity" ]] && _cs --section "terminal" "lang" "$conf_complexity"
    [[ -n "$conf_encrypt" ]] && _cs --section "terminal" "lang" "$conf_encrypt"
    [[ -n "$conf_alg" ]] && _cs --section "terminal" "lang" "$conf_alg"
    [[ -n "$conf_retry" ]] && _cs --section "terminal" "lang" "$conf_retry"
    [[ -n "$conf_timeout" ]] && _cs --section "terminal" "lang" "$conf_timeout"
    return 0
}