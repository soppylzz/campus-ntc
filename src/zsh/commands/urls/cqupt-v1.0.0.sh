#!/usr/bin/env zsh

_login() {
    local LOGIN_HEAD=(
        "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0"
        "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8"
        "Accept-Encoding: gzip, deflate" 
        "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
        "Connection: keep-alive"
        "Host: 192.168.200.2:801"
        "Referer: http://192.168.200.2/"
    )
    local LOGIN_QUERY=(
        "c=Portal"
        "a=login"
        "callback=dr1003"
        "login_method=1"    # computor login
        "wlan_user_mac=000000000000"
        "jsVersion=3.3.3"
        "wlan_user_ipv6="
        "wlan_ac_ip="
        "wlan_ac_name="
    )
    local LOGIN_DYNAMIC="curl -G \"http://192.168.200.2:801/eportal/?user_account=,0,%s@%s&user_password=%s&wlan_user_ip=%s&v=$((RANDOM % 9000 + 1000))\""

    local isp=$1
    local account=$2
    local password=$3
    local local_ip=$4
    local retry=$5
    local timeout=$6
    local debug=$7

    local joint=$(printf "$LOGIN_DYNAMIC" $account $isp $password $local_ip)
    for hitem in ${LOGIN_HEAD[@]}; do
        joint+=" -H \"$hitem\""
    done
    for qitem in ${LOGIN_QUERY[@]}; do
        joint+=" --data-urlencode \"$qitem\""
    done

    joint+=" --retry $retry"
    joint+=" --connect-timeout $timeout"
    if $debug; then 
        joint+=" --verbose"
        printf "eval: $joint\n\n" >&2
    else
        joint+=" --silent"
    fi
    # connect
    export http_proxy=
    export https_proxy=

    eval "$joint >/dev/null"
}

_logout() {
    local LOGOUT_HEAD=()
    
    local LOGOUT_QUERY=(
        "c=Portal"
        "a=unbind_mac"
        "callback=dr1002"
        "wlan_user_mac=000000000000"
        "jsVersion=3.3.3"
    )
    
    local LOGOUT_DYNAMIC="curl -G \"http://192.168.200.2:801/eportal/?user_account=%s@%s&wlan_user_ip=%s&v=$((RANDOM % 9000 + 1000))\""

    local isp=$1
    local account=$2
    local local_ip=$3
    local debug=$4

    local joint=$(printf "$LOGOUT_DYNAMIC" $account $isp $local_ip)
    for hitem in ${LOGOUT_HEAD[@]}; do
        joint+=" -H \"$hitem\""
    done
    for qitem in ${LOGOUT_QUERY[@]}; do
        joint+=" --data-urlencode \"$qitem\""
    done

    if $debug; then 
        joint+=" --verbose"
        printf "eval: $joint\n\n" >&2
    else
        joint+=" --silent"
    fi

    # connect
    export http_proxy=
    export https_proxy=

    eval "$joint >/dev/null"
}