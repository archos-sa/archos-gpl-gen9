#!/bin/sh
ADB=`which adb` && sudo $ADB kill-server && sudo $ADB start-server && adb devices
