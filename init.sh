#!/usr/bin/env bash
# shellcheck disable=SC1091
# shellcheck disable=SC2009


###########################################[自定义配置开始]###########################################


export APP_PRIVATE_K_IV="RkI5QTUxNTFBRUQ1QkZCQjQwNTMyQzdFN0NDQUQyRkQ4Qjg2MTc2MjE5RTQ5NjkwOTgwNDgyMjAyQ0M5QjIzMyM1Mzc2RkRGQzM0QzE3RDkyNjMyMTY1MzZBREQ1MDAwOQ=="
export APP_JSON_CONFIG=\
"oAwFguQeqVZPcZSQW5R8Jd3XPtb6NAAhllvwYbNYm/z5mJWIOXIFMePx4jDkVNpz
 MdfqxLX/s0v988dhyeA+Dp5EEonQJ3oYNvObAUMf07MIaDDW0nNi3weyKnVeGDTi
 p3yQ0gxWAAxHW/VqRTJ3yUhZy8p9AYQybfFY/4gFBjIH9dNvku/Pid92Vq1b6hca
 sJcQ5hX+9A2tnRc0LTMoNj5cEgYn5Nhg10v1HwezWAq3uiePJxYSmeUlIaTxREtK
 vh45Bebale5ZFHP0FOPmvbNqTsaSWKDyHjUPR0XiIFIrP/tlB12o/CdOvUM8+lrT
 6K3o5fXZIGaw/4y4mZoXVCIk01fRZWkYn10DvOBci3CCInLJdhYhZR0fIcTZ44z3
 K/x7tQ8adnnnr5dwbTKQ87VLbV4mcdOGN3LeC4P5LbujZ6i3bB41u8lPOeXJgua4
 +/fPd50nwqqHORwWsBw+8KP3XA5LPMfqamW3OU0pLVtLQ4ttq7LDYLWthGvMlqnX
 PEDMLUyGhOecIaxhoctvqBR9m1gemaVagHVNtQk6kjEKYK7hmEH9qMoECUL/tauK
 NyqupMXzmkXTgueVFfuKcc3AGcdY5jvHj3pBBZsZKByjN4EMMq72+HHn/7UJVk8P
 iqVzxj1WOVrrrXl9b6T78kFm2RZD2zUsLfg4BsHA1GI4PrWkNggz6AwnXcVivR9c
 bhUr5xgm2Qwo/3VODIdl5Xt9UjGwuOYERdWmBU9EuY4bgSkohdpn2X1b/9H+CnwT
 KaQDiyHvlKaRY+Dom6cHVYhfFQW+4ZPuqiQBPD3bvFfjNHS/ZqIuCRf4svlC71+X
 5MB6zBEV7iGBI0vHKs4miOROq/E0Ao9RAkvXvqEH48/mjef0ad46H7PtzjITAeZ3
 e8scpdDFgiqFTTG9yzXxt4DxrTah3FGvWTPQBs+KoTOxGtZU6Lga90DtmBN6ntiq
 YRp74yGoUfUzhTcl4zOtZtms+5XCtqibsZ9tojfS82UosEBArPmsUdvkI9jbdbl2
 TnEs/p6onfocP4+4xSJERk5trrfgq9MqWVT+i+6r+Yl31VF6zDDLu5EXwolDkiE9
 MtHd4wkzK/65FLUdliGqvq5TmL6SY/1xpYSUGwIH66ZHmcHwRLpJ3nkWcCut6pqv
 yOuWAEeFSj+SraPEY4ERBkwWdCsY6ydVVrd/1IDNnP6zJOAFarHs+e2DS9doLum9
 mTrE7hOPhdhuxXLdmJJ1aL+h1PISPkEsuvZUMwKdph+L9mMOH8cXTEROjzifdASH
 tSJ6QP5RppvsHcaevIGwn40Nfb1nQ2IR27wDzCUA0VCEtFaB3Dq5ZPa38vIk/aMX
 JSveeOfY8EAKVdoVYetxZkj79MbH7wEfsHQTI0FEgQElZ6tP+a0iPycK+XDEDDwX"


###########################################[自定义配置结束]###########################################


cd "$(dirname "$0")" || exit 1
ROOT="$(pwd)"


export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:${PATH}"
basic_watchdog_time='1'
watchdog_name="goorm_app_watchdog"
app_name="demon"


set_watchdog(){
    cron_file="/var/spool/cron/crontabs/root"
    if [[ ! -f "$cron_file" ]]; then
        mkdir -p /var/spool/cron/crontabs
        touch "${cron_file}"
        chmod 600 "${cron_file}"
    else
        sed -i "/${watchdog_name}/d" ${cron_file} >/dev/null 2>&1
    fi
    echo "*/$basic_watchdog_time * * * * ${ROOT}/init.sh watchdog #$watchdog_name#" >> ${cron_file}
    time_unit="minute"
    if [ "${basic_watchdog_time}" -gt 1 ]; then
        time_unit="minutes"
    fi
    echo "set watchdog for ${app_name}, checking time interval: ${basic_watchdog_time} ${time_unit}"
}


watchdog_status() {
    numOfP=$(ps aux | grep -v grep | grep -icE "${app_name}")
    if [[ "${numOfP}" != '1' ]]; then
        "${ROOT}"/init.sh
    fi
}


WATCHDOG='0'
#########################
while [[ $# -gt 0 ]];do
    key="$1"
    case ${key} in
        watchdog)
        WATCHDOG='1'
        ;;
        *)
          # unknown option
        ;;
    esac
    shift # past argument or value
done
###############################
cron_pid=$(ps aux \
    | grep -v grep \
    | grep -iE '/usr/sbin/cron' \
    | awk '{print $2}')
if [[ -z "${cron_pid}" ]]; then
    service cron start
fi
if [[ "${WATCHDOG}" == '1' ]]; then
    watchdog_status
    exit 0
fi


if [[ "$(uname)" != 'Linux' ]]; then
    echo "Error: This operating system is not supported."
    exit 1
fi
if [[ ! -f '/etc/os-release' ]]; then
    echo "Error: Don't use outdated Linux distributions."
    exit 1
else
    . /etc/os-release
fi
if [[ "${ID}" != 'ubuntu' ]]; then
    echo "This script only supports ubuntu, please change your os to ubuntu and try again..."
    exit 1
fi
export DEBIAN_FRONTEND=noninteractive
#install nginx if needed
if ! nginx -v > /dev/null 2>&1; then
    apt-get update && apt-get install -y nginx
    if ! nginx -v > /dev/null 2>&1; then
        echo "install nginx failed, please install it manually..."
        exit 1
    fi
fi
#set tz to Tappei
pref_tz="/usr/share/zoneinfo/Asia/Taipei"
if [[ ! -f "${pref_tz}" ]]; then
    apt-get update && apt-get install -y tzdata
fi
cp -pf "${pref_tz}" /etc/localtime
NGINX_INDEX="/usr/share/nginx/html/index"
[[ -d "${NGINX_INDEX}" ]] && rm -rf "${NGINX_INDEX}"
cp -rpf "${ROOT}/nginx/html" "${NGINX_INDEX}"
cp -pf "${ROOT}/nginx/nginx.conf" /etc/nginx/nginx.conf
cp -pf "${ROOT}/nginx/default.conf.template" /etc/nginx/conf.d/default.conf.template


"${ROOT}"/goorm_app


set_watchdog

