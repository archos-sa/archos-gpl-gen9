@echo off

:: some variables
set MLO=MLO_es2.2_gp
set WIPE=0
set RESTART=1
set FIRST=0
set BOOTLOADER=0

:: Make sure that we have all of the images
IF NOT EXIST boot.img goto NO_FILES

:: one or more args
FOR %%A IN (%*) DO (
    IF "%%A"=="/wipe"  set WIPE=1
    IF "%%A"=="/noreboot"  set RESTART=0
    IF "%%A"=="/first-time"  set FIRST=1
    if "%%A"=="/bootloader" set BOOTLOADER=1
)

IF /i %FIRST% EQU 1 set WIPE=1
IF /i %FIRST% EQU 1 set BOOTLOADER=1

:: Flash the bootloader
:FLASHBOOTLOADER
    IF /I %BOOTLOADER% EQU 1 (
        echo Flashing bootloader.....
        fastboot flash xloader %MLO%
        fastboot flash bootloader u-boot.bin

:: Reboot to load the new bootloader
:REBOOTBOOTLOADER
       echo Reboot: make sure new bootloader runs...
       fastboot reboot-bootloader

:: Wait for device to become available again (windows XP does not have sleep, so we simply ping ourselves).
:WAITFORBLAZE
        ping -n 5 127.0.0.1 > NUL
     )

:CREATEPART
    IF /I %FIRST% EQU 1 (
        echo Create GPT partition table
        fastboot oem format
    )

:SYSTEM
    echo Flash android partitions
    fastboot flash boot boot.img
    fastboot flash recovery recovery.img
    fastboot flash system system.img

:USERDATA
    IF /I %WIPE% EQU 1 (
        echo Flash android user data partitions
        fastboot flash userdata userdata.img
        fastboot flash cache cache.img
    )

:RESTART
:: if not specified, reboot at end.
    IF /I %RESTART%  EQU 1 (
        echo reboot
        fastboot reboot
    )

    goto DONE
    
:NO_FILES
        echo "no emmc files were found. Aborting."

:DONE
    echo DONE
