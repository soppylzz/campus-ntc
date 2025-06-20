#!/usr/bin/env zsh

[[ -n "${__CNTC_CONST__}" ]] && return
readonly __CNTC_CONST__=1

# Directories and files
readonly CNTC_PROJECT_ROOT="${${${${${(%):-%x}:A:h}:h}:h}:h}"

readonly CNTC_LOCALES_DIR="${CNTC_PROJECT_ROOT}/etc/locales"
readonly CNTC_LOGOS_DIR="${CNTC_PROJECT_ROOT}/etc/logos"

readonly CNTC_CONFIG_FILE="${HOME}/.config/cntc/config.conf"
readonly CNTC_LOG_FILE="${HOME}/.config/cntc/debug.log"
readonly CNTC_CAMPUS_CONFIG_FILE="${CNTC_PROJECT_ROOT}/etc/campus.conf"
readonly CNTC_TEMPLATE_CONFIG_FILE="${CNTC_PROJECT_ROOT}/etc/template.conf"

# Constants
readonly CNTC_DEFAULT_CORE_RETRY="3"
readonly CNTC_DEFAULT_CORE_TIMEOUT="10"
readonly CNTC_DEFAULT_CORE_MODE="once"
readonly CNTC_DEFAULT_ENCRYPT_ENABLE="true"
readonly CNTC_DEFAULT_ENCRYPT_ALGORITHM="aes"
readonly CNTC_DEFAULT_TERMINAL_LANG="zh"
readonly CNTC_DEFAULT_TERMINAL_COMPLEXITY="normal"

readonly CNTC_MAX_LOG_SIZE=1048576 # 1 MB

readonly CNTC_SUPPORTED_LOCALES=("zh" "en")
readonly CNTC_SUPPORTED_ALGORITHMS=("aes")
readonly CNTC_SUPPORTED_INI_SUFFIX=("TRANS" "CONFIG")
readonly CNTC_SUPPORTED_ISPS=("unicom" "telecom" "cmcc")

# Terminal colors
readonly BASE="\033[1;97;45mBASE\033[0m"
readonly LOG="\033[1;0mLOG\033[0m"
readonly INFO="\033[1;34mINFO\033[0m"
readonly WARN="\033[1;33mWARN\033[0m"
readonly ERROR="\033[1;31mERROR\033[0m"
readonly DEBUG="\033[1;35mDEBUG\033[0m"

readonly SCOPE="\033[1m%s\033[0m"
readonly TIMESTAMP="\033[38;5;244m%s\033[0m" 

# Project metadata
readonly CNTC_VERSION="0.0.1"
readonly CNTC_AUTHOR="Soppylzz"
readonly CNTC_LICENSE="MIT License"
readonly CNTC_START_YEAR="2025"
readonly CNTC_COPYRIGHT_YEAR=$(date +%Y)