#!/usr/bin/env zsh

[[ -n "${__CNTC_LOGGER__}" ]] && return
readonly __CNTC_LOGGER__=1

# Internal function to write log entries to file
cntc_write_log() {
    local level scope file_size message filestamp timestamp
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--level) level=$2 shift 2 ;;
            -s|--scope) scope=$2 shift 2 ;;
            -*) printf "[$BASE][$SCOPE]: Unknown option '$1'.\n" "logger.cntc_write_log" >&2; exit 1 ;;
            *) break ;;
        esac
    done
    
    message="$*"
    filestamp=$(date "+%Y-%m-%d")
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # Validate required parameters
    [[ ! -f $CNTC_LOG_FILE ]] && touch "$CNTC_LOG_FILE";
    [[ ! -w $CNTC_LOG_FILE ]] && { printf "[$BASE][$SCOPE]: Cannot write to log file '$CNTC_LOG_FILE'.\n" "logger.cntc_write_log" >&2; exit 1; }
    
    # Write formatted log entry to file
    printf "$TIMESTAMP " "$timestamp" >> "$CNTC_LOG_FILE"
    printf "[$level]" >> "$CNTC_LOG_FILE"
    [[ -n "$scope" ]] && {
        printf "[$SCOPE]: " "$scope" >> "$CNTC_LOG_FILE"
    }
    printf "$message\n" >> "$CNTC_LOG_FILE"

    # Check log file size and rotate if necessary
    # Handle different stat commands for macOS and Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then 
        file_size=$(stat -f%z "$CNTC_LOG_FILE")  # macOS stat format
    else 
        file_size=$(stat -c%s "$CNTC_LOG_FILE")  # Linux stat format
    fi
    
    # Rotate log file if size exceeds maximum
    [[ "$file_size" -gt "$CNTC_MAX_LOG_SIZE" ]] && {
        mv "$CNTC_LOG_FILE" "${CNTC_LOG_FILE}.${filestamp}"
        touch "$CNTC_LOG_FILE"
    }
}

# Main logging function for the application
cntc_log() {

    # Initialize local variables
    local level scope message
    local is_silent="false"

    # Parse command line options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--scope) scope="$2"; shift 2 ;;
            -d|--debug) level=$DEBUG; shift ;;
            -e|--error) level=$ERROR; shift ;;
            -w|--warn) level=$WARN; shift ;;
            -i|--info) level=$INFO; shift ;;
            -l|--log) level=$LOG; shift ;;
            -S|--silent) is_silent="true"; shift ;;
            -*) printf "[$BASE][$SCOPE]: Unknown option '$1'.\n" "logger.cntc_log" >&2; exit 1 ;;
            *) break ;;
        esac
    done

    # Get the log message from remaining arguments
    message="$*"

    # Validate required parameters
    [[ -z "$level" ]] && { printf "[$BASE][$SCOPE]: Log level must be specified.\n" "logger.cntc_log" >&2; exit 1; }
    [[ -z "$message" ]] && { printf "[$BASE][$SCOPE]: Log message cannot be empty.\n" "logger.cntc_log" >&2; exit 1; }

    # Write to log file for debug and error levels only
    [[ "$level" == "$DEBUG" || "$level" == "$ERROR" ]] && {
        local eval_run="cntc_write_log --level \$level "
        [[ -n "$scope" ]] && eval_run+="--scope \$scope "
        eval_run+="\$message"
        eval "$eval_run"
    }

    # Output to console unless silent mode is enabled
    $is_silent || printf "[$level][$SCOPE]: $message\n" "$scope" >&2
}