#!/usr/bin/env zsh

[[ -n "${__CNTC_FILE__}" ]] && return
readonly __CNTC_FILE__=1

# source <i18n|logger>

INI_SUFFIX=("TRANS" "CONFIG")

declare -gA CNTC_CONFIG     # Table
declare -gA CNTC_TRANS      # Table
declare -gA CNTC_CAMPUS     # Table

declare -ga CNTC_SAVE_USER  # List
declare -ga CNTC_ALL_CAMPUS # List

# ===================== BEFORE I18N INIT =====================

# ini_parse: Parse an ini file and export its contents to associative arrays.
ini_parse() {
    local file target awk_script

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--file) file="$2"; shift 2 ;;
            -t|--target) target="$2"; shift 2 ;;
            -*) cntc_log -s "conf_file.ini_parse" -d "Unknown option '$1'."; exit 1 ;;
            *) break ;;
        esac
    done

    [[ -z ${CNTC_SUPPORTED_INI_SUFFIX[(Ie)$target]} ]] && { cntc_log -s "conf_file.ini_parse" -d "Invalid target '$target', must be one of: ${INI_SUFFIX[@]}."; exit 1; }
    [[ ! -f "$file" ]] && { cntc_log -s "conf_file.ini_parse" -d "File '$file' does not exist."; exit 1; }

    awk_script='
        function escape(str) {
            gsub(/["$`\\]/, "\\\\&", str);
            return str;
        }
        
        BEGIN {
            FS="=";
            section="";
        }
        
        # process comment, empty line
        /^\s*$/ || /^\s*[;#]/ { next }
        
        # section line like [section]
        /^\s*\[[^]]+\]\s*$/ {
            gsub(/^\s*\[|\]\s*$/, "", $0)
            section = $0

            # Match format: <non-space>-<non-space> <non-space> (e.g., cqupt-v1.0.0 heqin)
            if (match(section, /^[^[:space:]]+[[:space:]]+[^[:space:]]+$/)) {
                printf "CNTC_SAVE_USER+=(\"%s\")\n", escape(section);
            }
            next
        }
        
        {
            key=$1;
            value=substr($0, length(key) + 2);
            
            gsub(/^[ \t]+|[ \t]+$/, "", key);
            gsub(/^[ \t]+|[ \t]+$/, "", value);
            
            if (key == "") next;
            
            if (value ~ /^".*"$/) {
                value=substr(value, 2, length(value) - 2);
            }
            else if (value ~ /^\x27.*\x27$/) {
                value=substr(value, 2, length(value) - 2);
            }
            
            if (section != "") {
                full_key=escape(section "." escape(key));
            } else {
                full_key=escape("no section" "." key);
            }

            printf "CNTC_%s[\"%s\"]=\"%s\"\n", target, full_key, escape(value);
        }
    '
    
    [[ "$target" == "CONFIG" ]] && CNTC_SAVE_USER=()
    eval "$(awk -v target="$target" "$awk_script" "$file")"
}

# ===================== AFTER I18N INIT =====================

# ini_update_item: Update or add a key-value pair in a section of an ini file.
ini_update_item() {
    local file section key value awk_script mkt_file
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--file) file="$2"; shift 2 ;;
            -s|--section) section="$2"; shift 2 ;;
            -*) cntc_log -s "conf_file.ini_update_item" -d "$(_ti "debug.unknown_option" "$1")"; exit 1 ;;
            *) break ;;
        esac
    done

    [[ -z "$file" || -z "$section" ]] && { cntc_log -s "conf_file.ini_update_item" -d "$(_t "conf_debug.file_section_need")"; exit 1; }
    key="$1"; value="$2";
    [[ -z "$key" || -z "$value" ]] && { cntc_log -s "conf_file.ini_update_item" -d "$(_t "conf_debug.key_value_need")"; exit 1; }

    awk_script='
        BEGIN {
            FS="="
            OFS="=" # for print key, value
            added = 0
            in_target = 0
        }

        # Match section line
        /^\s*\[.*\]\s*$/ {
            if (in_target && !added) {
                print key, value
                added = 1
            }
            gsub(/^\s*\[|\]\s*$/, "", $0)
            current_section = $0
            in_target = (current_section == section)
            print "[" current_section "]"
            next
        }

        # Inside target section
        in_target && /^[^#;].*=/ {
            curr_key = $1
            gsub(/^[ \t]+|[ \t]+$/, "", curr_key)
            if (curr_key == key) {
                print key, value
                added = 1
                next
            }
        }

        { print }

        END {
            if (!added) {
                if (!in_target) {
                    print ""
                    print "[" section "]"
                }
                print key, value
            }
        }
    '
    mkt_file="${file}.tmp.$$"
    awk -v section="$section" -v key="$key" -v value="$value" \
        "$awk_script" "$file" > "$mkt_file" && mv "$mkt_file" "$file"
    return 0
}

# ini_delete_item: Delete a key-value pair from a section in an ini file.
ini_delete_item() {
    local file section key awk_script mkt_file
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--file) file="$2"; shift 2 ;;
            -s|--section) section="$2"; shift 2 ;;
            -*) cntc_log -s "conf_file.ini_delete_item" -d "$(_t "debug.unknown_option" "$1")"; exit 1 ;;
            *) break ;;
        esac
    done

    key="$*"

    awk_script='
        BEGIN {
            FS="="
            in_target = 0
        }

        # Match section line
        /^\s*\[.*\]\s*$/ {
            gsub(/^\s*\[|\]\s*$/, "", $0)
            current_section = $0
            in_target = (current_section == section)
            print "[" current_section "]"
            next
        }

        # Inside target section
        in_target && /^[^#;].*=/ {
            curr_key = $1
            gsub(/^[ \t]+|[ \t]+$/, "", curr_key)
            if (curr_key == key) {
                next  # Skip this line (delete the key-value pair)
            }
        }

        { print }
    '

    mkt_file="${file}.tmp.$$"
    awk -v section="$section" -v key="$key" \
        "$awk_script" "$file" > "$mkt_file" && mv "$mkt_file" "$file"
    return 0
}

# ini_delete_item: Delete a key-value pair from a section in an ini file.
ini_delete_section() {
    local file section awk_script mkt_file
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--file) file="$2"; shift 2 ;;
            -s|--section) section="$2"; shift 2 ;;
            -*) cntc_log -s "conf_file.ini_delete_section" -d "$(_t "debug.unknown_option" "$1")"; exit 1 ;;
            *) break ;;
        esac
    done

    [[ -z "$file" || -z "$section" ]] && { cntc_log -s "conf_file.ini_update_item" -d "$(_t "conf_debug.file_section_need")"; exit 1; }

    mkt_file="${file}.tmp.$$"

    awk_script='
        BEGIN { 
            FS="="
            in_target = 0
        }

        /^\s*\[.*\]\s*$/ {
            gsub(/^\s*\[|\]\s*$/, "", $0)
            current_section = $0
            in_target = (current_section == section)

            if (!in_target) {
                print "[" current_section "]"
            }
            next
        }

        in_target { next }
        { print }
    '

    awk -v section="$section" \
        "$awk_script" "$file" > "$mkt_file" && mv "$mkt_file" "$file"
    return 0
}

# ===================== CAMPUS PARSE PART =====================

# ini_campus_parse: Parse the campus configuration file and export its contents.
ini_campus_parse() {
    local awk_script='
        function escape(str) {
            gsub(/["$`\\]/, "\\\\&", str);
            return str;
        }
        
        BEGIN {
            FS="=";
            section="";
        }
        
        # process comment, empty line
        /^\s*$/ || /^\s*[;#]/ { next }
        
        # section line like [section]
        /^\s*\[[^]]+\]\s*$/ {
            gsub(/^\s*\[|\]\s*$/, "", $0)
            section = $0

            printf "CNTC_ALL_CAMPUS+=(\"%s\")\n", escape(section)            
            next
        }
        
        {
            key=$1;
            value=substr($0, length(key) + 2);
            
            gsub(/^[ \t]+|[ \t]+$/, "", key);
            gsub(/^[ \t]+|[ \t]+$/, "", value);
            
            if (key == "") next;
            
            if (value ~ /^".*"$/) {
                value=substr(value, 2, length(value) - 2);
            }
            else if (value ~ /^\x27.*\x27$/) {
                value=substr(value, 2, length(value) - 2);
            }
            
            if (section != "") {
                full_key=escape(section "." escape(key));
            } else {
                full_key=escape("no section" "." key);
            }

            printf "CNTC_CAMPUS[\"%s\"]=\"%s\"\n", full_key, escape(value);
        }
    '
    eval "$(awk "$awk_script" "$CNTC_CAMPUS_CONFIG_FILE")"
}