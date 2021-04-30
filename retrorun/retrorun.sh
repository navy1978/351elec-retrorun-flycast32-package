#!/bin/bash
echo retrorun script called
source /etc/profile
BINPATH="/usr/bin"
EXECLOG="/tmp/logs/exec.log"
cd /storage/retrorun/armhf/retrorun/
# we need to create this file for the input (joypad):
touch /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
echo executing retrorun... with parm: "$1"
maxperf
/usr/bin/bash /storage/retrorun/armhf/retrorun.sh "$1"
normperf
