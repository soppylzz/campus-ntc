#!/usr/bin/env zsh

[[ -n "${__CNTC_USER_COMMAND__}" ]] && return
readonly __CNTC_USER_COMMAND__=1

CNTC_COMMAND_CURRENT_DIR="${${${(%):-%x}:A:h}:h}"
source "$CNTC_COMMAND_CURRENT_DIR/lib/init.sh"

user_ui() {
    cli_logo

    local complexity="$(_c "terminal.complexity")"

    cli_divider 50

    local select_campus=$(cli_options --border \
                                      --intro "$(_t "user.campus_intro")" \
                                      --end "$(_t "user.campus_end")" \
                                      --header "$(_t "user.campus_header")" \
                                      --footer "$(_t "user.campus_footer")" \
                                      "${CNTC_ALL_CAMPUS[@]}")

    local available_versions=()
    for key value in ${(kv)CNTC_CAMPUS}; do
        if [[ $key == *"$select_campus"* ]]; then
            available_versions+=($value)
        fi
    done

    local version=$(cli_options --border \
                                --intro "$(_t "user.version_intro")" \
                                --end "$(_t "user.version_end")" \
                                --header "$(_t "user.version_header")" \
                                --footer "$(_t "user.version_footer")" \
                                "${available_versions[@]}")

    # TODO: change into dynamic
    if $complexity; then
        _clean_lines 13
    else
        _clean_lines 4
    fi

    cli_campus_logo $select_campus


    local select_isp=$(cli_options --border \
                                   --intro "$(_t "user.isp_intro")" \
                                   --end "$(_t "user.isp_end")" \
                                   --header "$(_t "user.isp_header")" \
                                   --footer "$(_t "user.isp_footer")" \
                                   "${CNTC_SUPPORTED_ISPS[@]}")

    local alias_id=$(cli_input --border \
                         --end "$(_t "user.alias_end")" \
                         --intro "$(_t "user.alias_intro")" \
                         --header "$(_t "user.alias_header")" \
                         --footer "$(_t "user.alias_footer")")

    local account=$(cli_input --border \
                            --intro "$(_t "user.account_intro")" \
                            --end "$(_t "user.account_end")" \
                            --header "$(_t "user.account_header")" \
                            --footer "$(_t "user.account_footer")")

    local password=$(cli_input --border -H \
                            --intro "$(_t "user.password_intro")" \
                            --end "$(_t "user.password_end")" \
                            --header "$(_t "user.password_header")" \
                            --footer "$(_t "user.password_footer")")

    local confirm_pass=$(cli_input --border -H \
                            --intro "$(_t "user.confirm_pass_intro")" \
                            --end "$(_t "user.confirm_pass_end")" \
                            --header "$(_t "user.confirm_pass_header")" \
                            --footer "$(_t "user.confirm_pass_footer")")

    local is_override=$(cli_yn --line --border \
                              --intro "$(_t "user.override_intro")" \
                              --yes "$(_t "user.override_yes")" \
                              --no "$(_t "user.override_no")" \
                              --header "$(_t "user.override_header")" \
                              --footer "$(_t "user.override_footer")" \
                              )

    cli_divider --remember

    if $is_override; then
        local over_retry=$(cli_input --border \
                            --intro "$(_t "user.retry_intro")" \
                            --end "$(_t "user.retry_end")" \
                            --header "$(_t "user.retry_header")" \
                            --footer "$(_t "user.retry_footer")")
        local over_timeout=$(cli_input --border \
                            --intro "$(_t "user.timeout_intro")" \
                            --end "$(_t "user.timeout_end")" \
                            --header "$(_t "user.timeout_header")" \
                            --footer "$(_t "user.timeout_footer")")

        cli_divider --remember
    fi

    local confirm=$(cli_yn --intro "$(_t "user.confirm_intro")" \
                              --yes "$(_t "user.confirm_yes")" \
                              --no "$(_t "user.confirm_no")")
    
    if $confirm; then
        [[ $password != $confirm_pass ]] && {
            cntc_log -s "user.use_ui" -e "$(_t "user.password_tip")"
            exit 1
        }

        local section="$select_campus-$version $alias_id"
        _cs --section $section "isp" "$select_isp"
        _cs --section $section "account" "$account"
        # special
        _cs --section $section "password" "$password"

        if $is_override; then
            _cs --section $section "retry" "$over_retry"
            _cs --section $section "timeout" "$over_timeout"
        fi

        if $complexity; then
            printf "\n" >&2
            _centered "$(_t "user.confirm_finish")"
        else
            printf "$(_t "user.confirm_finish")\n" >&2
        fi
    fi
}

user() {
    local all=("$@")
    if [[ ${#all[@]} == 0 ]]; then
        user_ui
        return 0
    fi

    local mode alias_id
    local is_error="false" is_help="false"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--list) mode="list"; shift ; break ;;
            -d|--delete) mode="delete"; alias_id=$2; shift 2; break ;;
            -h|--help) is_help="true"; shift; break ;;
            *) is_error="true"; break ;;
        esac
    done

    local rest="$*"
    [[ $mode == "list" && -n $rest ]] && is_error="true"
    [[ $mode == "delete" ]] && {
        [[ -n $rest ]] && is_error="true"
        [[ -z ${CNTC_SAVE_USER[(Ie)$alias_id]} ]] && {
            is_error="true"
        }
    }
    $is_error && {
        cntc_log -s "cntc user" -w "$(_ti "debug.command_error" "$(printf "%s " "$@")" "cntc user --help")\n" >&2;
        _user_help
        exit 1
    }

    $is_help &&  {
        _user_help
        return 0
    }

    case $mode in 
        list)
            printf "$(_t "user.list")\n\n" >&2
            for item in ${CNTC_SAVE_USER[@]}; do
                if [[ "$(_ch "core.current")" == "true" ]]; then
                    if [[ "$item" == $(_c "core.current") ]]; then 
                        printf "* $item\n" >&2
                        continue;
                    fi
                fi
                printf "  $item\n" >&2
            done 
            printf "\n" >&2 ;;
        delete)
            _cd --section "$alias_id" ;;
    esac
    return 0
}