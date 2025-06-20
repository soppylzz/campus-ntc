#!/usr/bin/env zsh

[[ -n "${__CNTC_INTERACT__}" ]] && return
readonly __CNTC_INTERACT__=1

_read_key() {
    IFS=
    read -rsk1 key
    if [[ "$key" == $'\e' ]]; then
        read -rsk2 -t 1 rest
        key="$key$rest"
    fi
    echo "$key"
}

_get_border_top() {
    local width="$1"
    local header="$2"
    local _header_width=$(_term_length "$header")

    local border="╭─$header"
    local _c_width=$(( width + 3 - $_header_width ))
    for (( i=0; i<$_c_width; i++ )); do
        border="$border─"
    done
    echo "$border╮"
}

_get_border_middle() {
    local width="$1"
    local border=""
    for (( i=0; i<width + 4; i++ )); do
        border="$border─"
    done
    echo "$border"
}

_get_border_down() {
    local width="$1"
    local footer="$2"
    local _footer_width=$(_term_length "$footer")

    local border="╰"
    local _c_width=$(( width + 3 - $_footer_width ))
    for (( i=0; i<$_c_width; i++ )); do
        border="$border─"
    done
    echo "$border$footer─╯"
}

cli_options() {
    local intro end header footer
    local is_border="false"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -b|--border) is_border="true"; shift;;
            -i|--intro) intro="$2"; shift 2 ;;
            -h|--header) header="$2"; shift 2;;
            -f|--footer) footer="$2"; shift 2;;
            -e|--end) end="$2"; shift 2 ;;
            -*) cntc_log -s "ui.cli_options" -d "$(_ti "debug.unknown_option" "$1")"; exit 1 ;;
            *) break ;;
        esac
    done

    local options=("$@")
    local options_length="${#options[@]}"
    local complexity="$(_c -bc "terminal.complexity")"

    [[ $options_length -eq 0 ]] && {
        cntc_log -s "ui.cli_options" -d "$(_t "ui.empty_options")"
        exit 1
    }

    printf "\e[?25l" >&2
    local index=1
    if $complexity; then 
        # prepare: get border width
        local c_lines=("$intro")
        for opt in "${options[@]}"; do
            c_lines+="$opt"
        done

        local max_width=0
        for line in "${c_lines[@]}"; do
            local line_len=$(_term_length "$line")
            (( line_len > max_width )) && max_width=$line_len
        done

        # display
        while true; do
            s_lines_1=()
            $is_border && { s_lines_1+=" "; s_lines_1+="$(_get_border_top $max_width "$header")"; }
            s_lines_1+=" ";
            s_lines_1+="$intro"; 

            s_lines_1+=" "
            s_lines_1+="$(_get_border_middle $max_width)"

            s_lines_2=(" ")
            for ((i=1; i<=options_length; i++)); do
                if (( i == index)); then
                    s_lines_2+=$(printf "\033[35m❯ %s\033[0m\n" "${options[$i]}")
                else
                    s_lines_2+=$(printf "  %s\n" "${options[$i]}")
                fi
            done
            s_lines_3=()
            s_lines_3+=" "
            $is_border && { s_lines_3+="$(_get_border_down $max_width "$footer")"; }

            _centered -a $s_lines_1
            _centered -b -a $s_lines_2
            _centered -a $s_lines_3
            local line_num=$(( ${#s_lines_1[@]} + ${#s_lines_2[@]} + ${#s_lines_3[@]} ))

            key=$(_read_key)
            case $key in
                $'\e[A') ((index--)); ((index<1)) && index=$options_length ;;
                $'\e[B'|$'\t') ((index++)); ((index>$options_length)) && index=1 ;;
                "") _clean_lines $line_num; break ;;
                *) _clean_lines $line_num; continue ;;
            esac
            _clean_lines $line_num
        done

        printf "\n" >&2
        _centered $(printf "─── $end ───" "${options[$index]}")
    else
        local get
        while true; do
            printf "%s\n" $intro >&2
            for ((i=1; i<=options_length; i++)); do
                if (( i == index)); then
                    printf "\033[35m❯ %s\033[0m\n" "${options[$i]}" >&2
                else
                    printf "  %s\n" "${options[$i]}" >&2
                fi
            done
            key=$(_read_key)
            case $key in
                $'\e[A') ((index--)); ((index<1)) && index=$options_length ;;
                $'\e[B'|$'\t') ((index++)); ((index>$options_length)) && index=1 ;;
                "") _clean_lines "$(( options_length + 1 ))"; break ;;
                *) _clean_lines "$(( options_length + 1 ))"; continue ;;
            esac
            _clean_lines "$(( options_length + 1 ))"
        done
        
        printf "$end\n" "${options[$index]}" >&2
    fi
    printf "\e[?25h" >&2
    trap - EXIT

    echo "${options[$index]}"
}

_get_yn() {
    local inter_pad=10 yn="$1"
    if $yn; then
        echo "\033[35m❯ $(_t "ui.yn_yes")\033[0m$(printf "%*s" "$inter_pad" "")  $(_t "ui.yn_no")"
    else
        echo "  $(_t "ui.yn_yes")$(printf "%*s" "$inter_pad" "")\033[35m❯ $(_t "ui.yn_no")\033[0m"
    fi
}

cli_yn() {
    local yes_text no_text intro return footer header lined_pattern
    local is_border="false"
    local is_lined="false"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--line) is_lined="true"; shift;;
            -b|--border) is_border="true"; shift;;
            -i|--intro) intro="$2"; shift 2;;
            -h|--header) header="$2"; shift 2;;
            -f|--footer) footer="$2"; shift 2;;
            -n|--no) no_text="$2"; shift 2;;
            -y|--yes) yes_text="$2"; shift 2;;
            -*) cntc_log -s "ui.cli_yn" -d "$(_ti "debug.unknown_option" $1)"; exit 1 ;;
            *) break ;;
        esac
    done

    local complexity="$(_c -bc "terminal.complexity")"

    if $complexity; then 
        printf "\e[?25l" >&2
        local c_lines
        # prepare: get border width
        return="true"
        c_lines=(
            "$(_get_yn "false")" 
            "$(_get_yn "true")" 
            "$yes_text" 
            "$no_text"
        )
        intro_split=("${(@f)intro}")
        for is in "${intro_split[@]}"; do
            c_lines+="$is"
        done

        local max_width=0

        for line in "${c_lines[@]}"; do
            local line_len=$(_term_length "$line")
            (( line_len > max_width )) && max_width=$line_len
        done

        # display
        while true; do
            s_lines=()
            $is_border && { s_lines+=" ";s_lines+="$(_get_border_top $max_width "$header")"; }
            s_lines+=" ";
            s_lines+="$intro?"; 
            s_lines+=" ";
            s_lines+="$(_get_yn "$return")";
            s_lines+=" ";
            $is_border && { s_lines+="$(_get_border_down $max_width "$footer")"; }

            _centered -a $s_lines
            local line_num=${#s_lines[@]}

            key=$(_read_key)
            case $key in
                $'\e[C' | $'\e[D') 
                    if $return; then 
                        return="false"
                    else
                        return="true"
                    fi
                    _clean_lines $line_num
                    continue ;;
                "") break ;;
                *) _clean_lines $line_num ;;
            esac
        done

        _clean_lines $line_num

        printf "\e[?25h" >&2
        trap - EXIT
        
        if $is_lined; then
            lined_pattern="─── %s ───"
        else
            lined_pattern=" %s "
        fi

        printf "\n" >&2
        if $return; then
            _centered "$(printf "$lined_pattern" $yes_text)" >&2
        else
            _centered "$(printf "$lined_pattern" $no_text)" >&2
        fi
    else
        local get
        local try_again=1
        while true; do
            printf "%s (y/N):" $intro >&2
            read get
            case $get in
                y|Y) return="true"; _clean_lines $try_again; break ;; 
                n|N) return="false";  _clean_lines $try_again; break;;
                *) _clean_lines $try_again; printf "$(_t "ui.yn_tip")\n" >&2; try_again=2 ;;
            esac
        done
        if $return; then
            printf "%s\n" $yes_text >&2
        else
            printf "%s\n" $no_text >&2
        fi
    fi
    echo "$return"
}

cli_input() {
    local intro header footer end
    local is_border="false"
    local is_hidden="false"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -b|--border) is_border="true"; shift ;;
            -H|--hidden) is_hidden="true"; shift ;;
            -i|--intro) intro="$2"; shift 2 ;;
            -h|--header) header="$2"; shift 2 ;;
            -f|--footer) footer="$2"; shift 2 ;;
            -e|--end) end="$2"; shift 2 ;;
            -*) cntc_log -s "ui.cli_input" -d "$(_ti "debug.unknown_option" "$1")"; exit 1 ;;
            *) break ;;
        esac
    done

    local complexity="$(_c -bc "terminal.complexity")"

    if $complexity; then
        printf "\e[?25l" >&2

        local get_str str_width display_str
        local get_chars=()

        while true; do
            get_str=""
            for _get in ${get_chars[@]}; do
                get_str="$get_str$_get"
            done

            # display
            if $is_hidden; then
                display_str="$intro"
            else
                display_str="$intro$get_str"
            fi

            str_width=$(_term_length "$display_str")
            s_lines=()
            $is_border && { s_lines+=" "; s_lines+="$(_get_border_top $str_width "$header")"; }
            s_lines+=" "
            s_lines+="$display_str"
            s_lines+=" "
            $is_border && { s_lines+="$(_get_border_down $str_width "$footer")"; }
            
            _centered -a $s_lines
            local line_num=${#s_lines[@]}

            # read
            read -rsk1 char
            [[ "$char" == $'\n' ]] && {
                _clean_lines $line_num;
                [[ -z "$get_str" ]] && continue;
                break;
            }
            if [[ "$char" == $'\x7f' ]]; then
                [[ -n $get_chars ]] && get_chars=("${get_chars[@]:0:${#get_chars[@]}-1}")
                _clean_lines $line_num
                continue
            fi
            if [[ "$char" == $'\e' ]]; then
                read -rsk2 -t 1 extra
                char+="$extra"
                case "$char" in
                    $'\e[A'|$'\e[B'| $'\e[C'|$'\e[D'|$'\e[H'| $'\e[F'|\
                    $'\eOP'|$'\eOQ'| $'\eOR'|$'\eOS') _clean_lines $line_num; continue ;;
                    
                    $'\e[1'|$'\e[2') 
                        read -rsk2 -t 1 extra2;   
                        char="$char$extra2"

                        case "$char" in
                            $'\e[15~'|$'\e[17~'| $'\e[18~'|\
                            $'\e[19~'|$'\e[20~'| $'\e[21~'|\
                            $'\e[23~'|$'\e[24~') _clean_lines $line_num; continue ;;
                        esac
                        ;;
                esac
            fi
            get_chars+=("$char")
            _clean_lines $line_num
        done
        
        if $is_hidden;then
            show_str=" "
        else
            show_str="$get_str"
        fi

        printf "\n" >&2
        _centered $(printf "─── $end ───" "$show_str")

        printf "\e[?25h" >&2
        trap - EXIT

        echo "$get_str"
    else
        local get=""
        printf "%s" $intro >&2
        $is_hidden && { stty -echo; trap 'stty echo' EXIT; }
        read get
        $is_hidden && { stty echo; }
        if $is_hidden;then
            printf "\n" >&2
            _clean_lines 1
            printf "$end\n" >&2
        else
            _clean_lines 1
            printf "$end\n" "$get" >&2
        fi
        
        echo "$get"
    fi
}