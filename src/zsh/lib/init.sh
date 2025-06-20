#!/usr/bin/env zsh

[[ -n "${__CNTC_INIT__}" ]] && return
readonly __CNTC_INIT__=1

CNTC_INIT_CURRENT_DIR="${${(%):-%x}:A:h}"

source "$CNTC_INIT_CURRENT_DIR/const.sh"

source "$CNTC_INIT_CURRENT_DIR/utils/network.sh"
source "$CNTC_INIT_CURRENT_DIR/utils/print.sh"
source "$CNTC_INIT_CURRENT_DIR/utils/tool.sh"
source "$CNTC_INIT_CURRENT_DIR/utils/help.sh"

source "$CNTC_INIT_CURRENT_DIR/ui/interact.sh"
source "$CNTC_INIT_CURRENT_DIR/ui/print.sh"

source "$CNTC_INIT_CURRENT_DIR/logger/logger.sh"

source "$CNTC_INIT_CURRENT_DIR/conf/file.sh"
source "$CNTC_INIT_CURRENT_DIR/conf/init.sh"
source "$CNTC_INIT_CURRENT_DIR/conf/inner.sh"
source "$CNTC_INIT_CURRENT_DIR/conf/var.sh"

conf_init