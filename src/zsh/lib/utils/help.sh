#!/usr/bin/env zsh

[[ -n "${__CNTC_HELP_COMMAND__}" ]] && return
readonly __CNTC_HELP_COMMAND__=1

_cntc_version() {
    printf "$(_ti "help.version" "$CNTC_VERSION")\n" >&2;
    printf "$(_ti "help.copyright" "$CNTC_START_YEAR" "$CNTC_COPYRIGHT_YEAR" "$CNTC_AUTHOR")\n" >&2;
    printf "$(_ti "help.license" "$CNTC_LICENSE")\n" >&2;
}

_cntc_help() {
    printf "$(_t "help.cntc_ht")\n" >&2;
    printf "$(_t "help.cntc_hi")\n\n" >&2;
    printf "$(_t "help.cntc_ho")\n" >&2;
    printf "$(_t "help.cntc_opt1")\n" >&2;
    printf "$(_t "help.cntc_opt2")\n" >&2;
    printf "$(_t "help.cntc_opt3")\n" >&2;
    printf "$(_t "help.cntc_opt4")\n" >&2;
    printf "$(_t "help.cntc_opt5")\n" >&2;
    printf "$(_t "help.cntc_opt6")\n\n" >&2;
    printf "$(_t "help.cntc_opt0")\n" >&2;
}

_configure_help() {
    printf "$(_t "help.configure_ht")\n" >&2;
    printf "$(_t "help.configure_hi")\n\n" >&2;
    printf "$(_t "help.configure_ho")\n" >&2;
    printf "$(_t "help.configure_opt1")\n\n" >&2;
    printf "$(_t "help.configure_opt0")\n" >&2;
}

_config_help() {
    printf "$(_t "help.config_ht")\n" >&2;
    printf "$(_t "help.config_hi")\n\n" >&2;
    printf "$(_t "help.config_ho")\n" >&2;
    printf "$(_t "help.config_opt1")\n" >&2;
    printf "$(_t "help.config_opt2")\n" >&2;
    printf "$(_t "help.config_opt3")\n" >&2;
    printf "$(_t "help.config_opt4")\n" >&2;
    printf "$(_t "help.config_opt5")\n" >&2;
    printf "$(_t "help.config_opt6")\n\n" >&2;
    printf "$(_t "help.config_opt0")\n" >&2;
}

_user_help() {
    printf "$(_t "help.user_ht")\n" >&2;
    printf "$(_t "help.user_hi")\n\n" >&2;
    printf "$(_t "help.user_ho")\n" >&2;
    printf "$(_t "help.user_opt1")\n" >&2;
    printf "$(_t "help.user_opt2")\n" >&2;
    printf "$(_t "help.user_opt3")\n\n" >&2;
    printf "$(_t "help.user_opt0")\n" >&2;
}

_login_help() {
    printf "$(_t "help.login_ht")\n" >&2;
    printf "$(_t "help.login_hi")\n\n" >&2;
    printf "$(_t "help.login_ho")\n" >&2;
    printf "$(_t "help.login_opt1")\n\n" >&2;
    printf "$(_t "help.login_opt0")\n" >&2;
}

_logout_help() {
    printf "$(_t "help.logout_ht")\n" >&2;
    printf "$(_t "help.logout_hi")\n\n" >&2;
    printf "$(_t "help.logout_ho")\n" >&2;
    printf "$(_t "help.logout_opt1")\n\n" >&2;
    printf "$(_t "help.logout_opt0")\n" >&2;
}