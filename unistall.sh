#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later

# Load functions needed to send messages to the console
. /etc/profile


INSTALL_PATH="/storage/retrorun_flycast32"
BINARY="retrorun_flycast32"
CFG="/storage/.emulationstation/es_systems.cfg"
START_SCRIPT="$BINARY.sh"

MYARCH="armhf"

if grep -q '<name>dreamcast</name>' "$CFG"
then
	xmlstarlet ed -L -P -d "/systemList/system[name='dreamcast']" $CFG
fi

if [ -f /storage/.config/emulationstation/scripts/retrorun_flycast32.sh ]
then
  rm -f /storage/.config/emulationstation/scripts/retrorun_flycast32.sh
fi

rm -rf ${INSTALL_PATH}