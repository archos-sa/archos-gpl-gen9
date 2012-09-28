#!/system/bin/sh
l2test -w -X ertm -N 1 -H 5 -K 5 -b 100 -Y
hcitool dc $1
