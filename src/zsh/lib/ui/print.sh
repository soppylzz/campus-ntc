#!/usr/bin/env zsh

[[ -n "${__CNTC_UI_PRINT__}" ]] && return
readonly __CNTC_UI_PRINT__=1

# logo width cache
REMEMEBER_CAMPUS_WIDTH=0

cli_logo() {
    local complexity="$(_c "terminal.complexity")"
    
    case "$complexity" in 
        "false"|"False") printf "$(_t "ui.logo")\n" >&2;;
        "true"|"True") _centered -f "$CNTC_LOGOS_DIR/cntc"; _centered -a "" "$(_t "ui.logo")";;
    esac
}

cli_divider() {
    local d_width divider=""
    local is_remember="false"
    local complexity="$(_c "terminal.complexity")"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r|--remember) is_remember="true"; shift;;
            -*) cntc_log -s "ui.cli_divider" -d "$(_ti "debug.unknown_option" "$1")"; exit 1 ;;
            *) break ;;
        esac
    done

    $is_remember && d_width=$REMEMEBER_CAMPUS_WIDTH || d_width=$1
    for (( i=0; i<d_width; i++ )); do
        divider+="─"
    done

    case "$complexity" in 
        "false"|"False") printf "\n" >&2;;
        "true"|"True") printf "\n" >&2; _centered $divider ;;
        *) cntc_log -s "ui.cli_logo" -e "$(_t "error.complexity")"; exit 1;;
    esac
}

cli_campus_logo() {
    local campus="$1"
    local complexity="$(_c "terminal.complexity")"
    local campus_logo_file="$CNTC_LOGOS_DIR/$campus"
    case "$complexity" in 
        "true"|"True") 
            local line_len
            local max_width=0
            while IFS= read -r line; do
                line_len=$(_term_length "$line")
                (( $line_len > max_width )) && max_width=$line_len
            done < $campus_logo_file
            _centered -f "$campus_logo_file"; 
            _centered "$(_t "ui.cqupt_logo")"
            REMEMEBER_CAMPUS_WIDTH=$max_width
            cli_divider --remember
            ;;
        "false"|"False")  
            while IFS= read -r line; do
                printf "%s\n" "$line" >&2
            done < $campus_logo_file
            printf "$(_t "ui.cqupt_logo")\n"
            cli_divider 0
            ;;
    esac
}