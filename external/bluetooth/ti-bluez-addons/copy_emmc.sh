#!/bin/bash

TERMCOLOR_RED='\E[00;31m'
TERMCOLOR_GREEN='\E[00;32m'
TERMCOLOR_YELLOW='\E[00;33m'
TERMCOLOR_BLUE='\E[00;34m'
TERMCOLOR_LBLUE='\E[00;36m'
TERMCOLOR_BOLD='\E[00;38m'
TERMCOLOR_ENABLE='\033[1m'
TERMCOLOR_DISABLE='\033[0m'

export LC_ALL=C


function echo_red() {
	echo -en $TERMCOLOR_RED"${TERMCOLOR_ENABLE}$*${TERMCOLOR_DISABLE}"
	echo
}

function echo_green() {
	echo -en $TERMCOLOR_GREEN"${TERMCOLOR_ENABLE}$*${TERMCOLOR_DISABLE}"
	echo
}

function echo_yellow() {
	echo -en $TERMCOLOR_YELLOW"${TERMCOLOR_ENABLE}$*${TERMCOLOR_DISABLE}"
	echo
}

function echo_blue() {
	echo -en $TERMCOLOR_BLUE"${TERMCOLOR_ENABLE}$*${TERMCOLOR_DISABLE}"
	echo
}

function echo_lblue() {
	echo -en $TERMCOLOR_LBLUE"${TERMCOLOR_ENABLE}$*${TERMCOLOR_DISABLE}"
	echo
}

function echo_bold() {
	echo -en $TERMCOLOR_BOLD"${TERMCOLOR_ENABLE}$*${TERMCOLOR_DISABLE}"
	echo
}


main()
{
    # some variables
    FASTBOOT=./fastboot
    PRODUCT_OUT=.
    MLO=MLO_es2.2_gp
    WIPE="0"
    REBOOT="1"
    FIRST="0"
    BOOTLOADER="0"

    # Make sure that we have all of the images
    if [ ! -f boot.img -o ! -f ramdisk.img -o ! -f system.img ]; then
        echo_red "no emmc files were found. Aborting."
        return 1
    fi

    #one or more args
    while [ "$#" -gt 0 ]
    do
        case "$1" in
            --wipe) WIPE=1; shift;;
            --noreboot)  REBOOT=0;  shift;;
            --first-time) FIRST=1; WIPE=1; BOOTLOADER=1; shift;;
            --bootloader) BOOTLOADER=1; shift;;
            *) shift;;
        esac
    done

    # Flash the bootloader
    if [ "$BOOTLOADER" = "1" ]; then
        echo_yellow "Flashing bootloader....."
        sudo $FASTBOOT flash xloader 	./$MLO
        sudo $FASTBOOT flash bootloader 	./u-boot.bin

        # Reboot to load the new bootloader
        echo_yellow "Reboot: make sure new bootloader runs..."
        sudo $FASTBOOT reboot-bootloader

        # Wait for device to become available again
        sleep 5
    fi

    if [ "$FIRST" = "1" ]; then
        echo_yellow "Create GPT partition table"
        sudo $FASTBOOT oem format
    fi

    echo_yellow "Flash android partitions"
    sudo $FASTBOOT flash boot 		$PRODUCT_OUT/boot.img
    #sudo $FASTBOOT flash recovery	$PRODUCT_OUT/recovery.img
    sudo $FASTBOOT flash system 		$PRODUCT_OUT/system.img

    if [ "$WIPE" = "1" ]; then
        echo_yellow "Flash android user data partitions"
        sudo $FASTBOOT flash userdata 	$PRODUCT_OUT/userdata.img
        sudo $FASTBOOT flash cache 		./cache.img
        sudo $FASTBOOT flash efs        ./efs.img
    fi

    # If not specified, reboot at end.
    if [ "$REBOOT" = "1" ]; then
        sudo $FASTBOOT reboot
    else
        echo_yellow "Reboot your device."    
    fi

}

main $*
