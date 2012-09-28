#!/bin/bash

source tibluez_common.sh

count=0
while true; do 
    echo_adbts "Turning On..."
    adb_service_call bluetooth 3
    echo_adbts "Waiting after On"
    sleep 10
    echo_adbts "Starting Scan"
    adb_service_call bluetooth 12
    echo_adbts "Waiting for some scan results"
    sleep 5
    echo_adbts "Turning off"
    adb_service_call bluetooth 4 i32 0
    echo_adbts "Waiting after off"
    sleep 10
    count=$(( $count + 1 ))
    echo_adbts "On/Off #$count"
done
