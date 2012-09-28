#!/bin/bash

_RED='\033[00;31m'
_GREEN='\033[00;32m'
_YELLOW='\033[00;33m'
_BLUE='\033[00;34m'
_LBLUE='\033[00;36m'
_BOLD='\033[00;38m'
_ENABLE='\033[1m'
_DISABLE='\033[0m'

#_RED=''
#_GREEN=''
#_YELLOW=''
#_BLUE=''
#_LBLUE=''
#_BOLD=''
#_ENABLE=''
#_DISABLE=''

# Echo with ADB Timestamp for synchronizing with the logcat time stamps
echo_adbts()
{
    echo -e ${_YELLOW}${_ENABLE} `adb shell date | awk '{print $4}'`:${_DISABLE}$*
}

adb_service_call()
{
    SVC=$1
    FUNC=$2
    FUNC_NAME=$2
    SVCINDEX=`echo $SVC | sed -e 's/^./\U&\E/g'`.aidl
    SVCINDEX="I${SVCINDEX}"
    if [ -e ${SVCINDEX} ]; then
        FUNC_NAME=`sed 's/\/\*.*//' ${SVCINDEX} | sed 's/;//' | sed -e 's/^ \*.*//' -e 's/^package.*//' -e 's/^import.*//' -e 's/^interface.*//' -e 's/^\t*//' -e 's/^ //' -e 's/{//' -e 's/}//' | sed '/^\s*#/d;/^\s*$/d' | sed -n "${FUNC}p"`
    fi
    echo_adbts "${_BOLD}${_ENABLE}${SVC}:${_GREEN}${FUNC_NAME}" ${_LBLUE}`adb shell service call $SVC $FUNC` "${_DISABLE}"
}


