#!/system/bin/sh
setprop service.adb.tcp.port -1
stop adbd
start adbd