#!/usr/bin/env zsh

[[ -n "${__CNTC_AUTH_COMMAND__}" ]] && return
readonly __CNTC_AUTH_COMMAND__=1

CNTC_COMMAND_CURRENT_DIR="${${${(%):-%x}:A:h}:h}"
source "$CNTC_COMMAND_CURRENT_DIR/lib/init.sh"

login() {
    local rest
    local is_debug="false" is_help="false" is_error="false"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--debug) is_debug="true"; shift; break ;;
            -h|--help) is_help="true"; shift; break ;;
            *) is_error="true"; break ;;
        esac
    done

    rest="$*"
    [[ -n "$rest" ]] && is_error="true"

    $is_error && {
        cntc_log -s "cntc login" -w "$(_ti "debug.command_error" "$(printf "%s " "$@")" "cntc login --help")\n" >&2;
        _login_help
        exit 1
    }

    $is_help &&  {
        _login_help
        return 0
    }


    cli_logo

    local complexity="$(_c "terminal.complexity")"

    cli_divider 50

    local select_campus=$(cli_options --border \
                                      --intro "$(_t "login.campus_intro")" \
                                      --end "$(_t "login.campus_end")" \
                                      --header "$(_t "login.campus_header")" \
                                      --footer "$(_t "login.campus_footer")" \
                                      "${CNTC_ALL_CAMPUS[@]}")

    local available_versions=()
    for key value in ${(kv)CNTC_CAMPUS}; do
        if [[ $key == *"$select_campus"* ]]; then
            available_versions+=($value)
        fi
    done

    local version=$(cli_options --border \
                                --intro "$(_t "login.version_intro")" \
                                --end "$(_t "login.version_end")" \
                                --header "$(_t "login.version_header")" \
                                --footer "$(_t "login.version_footer")" \
                                "${available_versions[@]}")

    # TODO: change into dynamic
    if $complexity; then
        _clean_lines 13
    else
        _clean_lines 4
    fi

    cli_campus_logo $select_campus

    local limit_account=()
    for item in ${CNTC_SAVE_USER[@]}; do
        if [[ $item == *"$select_campus-$version"* ]]; then
            limit_account+=("$item")
        fi
    done

    local alias_id=$(cli_options --border \
                                --intro "$(_t "login.version_intro")" \
                                --end "$(_t "login.version_end")" \
                                --header "$(_t "login.version_header")" \
                                --footer "$(_t "login.version_footer")" \
                                "${limit_account[@]}")

    cli_divider --remember

    local confirm=$(cli_yn --intro "$(_t "login.confirm_intro")" \
                              --yes "$(_t "login.confirm_yes")" \
                              --no "$(_t "login.confirm_no")")

    if $confirm; then
        local current_dir="${${(%):-%x}:A:h}"
        source "$current_dir/urls/$select_campus-$version.sh"
        
        local retry timeout isp account password local_ip is_connect
        retry=$(_c "core.retry")
        timeout=$(_c "core.timeout")
        account=$(_c "$alias_id.account")
        password=$(_c "$alias_id.password")
        isp=$(_c "$alias_id.isp")
        $(_ch "$alias_id.retry") && retry=$(_c "$alias_id.retry")
        $(_ch "$alias_id.timeout") && timeout=$(_c "$alias_id.timeout")
        local_ip=$(get_ip)

        _login $isp $account $password $local_ip $retry $timeout $is_debug

        is_connect=$(check_internet)
        if $is_connect; then
            if $complexity; then
                printf "\n" >&2
                _centered "$(_t "login.confirm_finish")"
            else
                printf "$(_t "login.confirm_finish")\n" >&2
            fi

            # save current user
            _cs --section "core" "current" "$alias_id"
        else
            if $complexity; then
                printf "\n" >&2
                _centered "$(_t "login.confirm_failed")"
            else
                printf "$(_t "login.confirm_failed")\n" >&2
            fi
        fi
    fi
}

logout() {
    local is_debug="false" is_help="false" is_error="false"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--debug) is_debug="true"; shift; break ;;
            -h|--help) is_help="true"; shift; break ;;
            *) is_error="true"; break ;;
        esac
    done

    rest="$*"

    [[ -n "$rest" ]] && is_error="true"

    $is_error && {
        cntc_log -s "cntc logout" -w "$(_ti "debug.command_error" "$(printf "%s " "$@")" "cntc logout --help")\n" >&2;
        _logout_help
        exit 1
    }

    $is_help &&  {
        _logout_help
        return 0
    }

    local confirm campus infos alias_id=$(_c "core.current")
    IFS=" -" read -r -A infos <<< "$alias_id"

    campus=${infos[1]}
    version=${infos[2]}

    cli_campus_logo $campus

    confirm=$(cli_yn --intro "$(_ti "logout.confirm_intro" "$alias_id")" \
                              --yes "$(_t "logout.confirm_yes")" \
                              --no "$(_t "logout.confirm_no")" \
                              )

    if $confirm; then
        local current_dir="${${(%):-%x}:A:h}"
        source "$current_dir/urls/$campus-$version.sh"

        local isp account local_ip is_connect

        account=$(_c "$alias_id.account")
        isp=$(_c "$alias_id.isp")

        local_ip=$(get_ip)

        _logout $isp $account $local_ip $is_debug
        is_connect=$(check_internet)
        if $is_connect; then
            # save current user
            if $complexity; then
                printf "\n" >&2
                _centered "$(_t "logout.confirm_failed")"
            else
                printf "$(_t "logout.confirm_failed")\n" >&2
            fi
        else
            _cd --section "core" "current"
            if $complexity; then
                printf "\n" >&2
                _centered "$(_t "logout.confirm_finish")"
            else
                printf "$(_t "logout.confirm_finish")\n" >&2
            fi
        fi
    fi
}