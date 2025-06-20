#!/usr/bin/env zsh

[[ -n "${__CNTC_UTILS_PRINT__}" ]] && return
readonly __CNTC_UTILS_PRINT__=1

_term_length() {
    local length=0
    local text=$(printf "$1")
    local clean_text=$(printf "%s" "$text" | sed -E $'s/\x1B\\[[0-9;]*[A-Za-z]//g')
    local text_len=${#clean_text[@]}

    for (( i=1; i<=text_len; i++ )); do
        local byte_length=$(printf "${clean_text[$i]}" | wc -c | awk '{printf $1}')
        if [[ "$byte_length" -eq 3 || "$byte_length" -eq 4 ]];then
            # support emoji and chinese character
            local char="${clean_text[$i]}"
            case "$char" in
                ╭|╮|╰|╯|─|❯) ((length++)) ;;
                *) ((length+=2)) ;;
            esac
        elif [[ "$byte_length" -eq 1 ]]; then
            ((length++))
        else
            # unexpected byte length
            cntc_log -s "utils_print._term_length" -d "$(_ti "unexpected_length" "$byte_length")"
            exit 1;
        fi
    done
    echo "$length"
}

_centered() {
    local file=""
    local is_lines=false
    local is_block=false
    
    term_width=$(tput cols)

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--file) file="$2"; shift 2 ;;
            -a|--array) is_lines=true; shift ;;
            -b|--block) is_block=true; shift ;;
            -*) cntc_log -s "utils_print._centered" -d "$(_ti "debug.unknown_option" "$1")"; exit 1;;
            *) break ;;
        esac
    done

    local lines=()

    # fill
    if [[ -n "$file" ]]; then
        if [[ -f "$file" ]]; then
            IFS=$'\n'; lines=($(<"$file"));
        else
            cntc_log -s "utils_print._centered" -d "$(_ti "debug.file_not_found" "$file")"
            exit 1;
        fi
    elif $is_lines; then
        lines=("$@")
    else
        str=$(printf "$*")
        lines=("${(@f)str}")
    fi

    if $is_block; then 
        # Determine block width (longest line)
        local max_width=0
        for line in "${lines[@]}"; do
            local line_len=$(_term_length "$line")
            (( $line_len > max_width )) && max_width=$line_len
        done

        # Calculate left padding for block
        local block_pad=$(( (term_width - max_width) / 2 ))
        [[ $block_pad -lt 0 ]] && block_pad=0

        for line in "${lines[@]}"; do
            printf "%*s%s\n" $block_pad "" "$line" >&2
        done
    else
        for line in "${lines[@]}"; do
            local line_len=$(_term_length "$line")
            pad=$(( (term_width - $line_len) / 2 ))
            [[ $pad -lt 0 ]] && pad=0
            printf "%*s$line\n" $pad "" >&2
        done
    fi
}

_clean_lines() { 
    local num="$1" 
    for ((i=0; i<num; i++)); do 
        printf "\033[1A\033[2K" >&2; 
    done; 
}