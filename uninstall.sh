#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later

# Load functions needed to send messages to the console
. /etc/profile


INSTALL_PATH="/storage/retrorun"
BINARY="retrorun"
CFG="/storage/.emulationstation/es_systems.cfg"
TMP_CFG_DEL="/storage/.emulationstation/es_systems_del.cfg"
START_SCRIPT="$BINARY.sh"

MYARCH="armhf"

if grep -q 'retrorun' "$CFG"
then
	xmlstarlet ed -d '/systemList/system[name="dreamcast"]/emulators/emulator[@name="retrorun"]' $CFG > $TMP_CFG_DEL
	rm $CFG
	mv $TMP_CFG_DEL $CFG
	xmlstarlet ed -d '/systemList/system[name="naomi"]/emulators/emulator[@name="retrorun"]' $CFG > $TMP_CFG_DEL
	rm $CFG
	mv $TMP_CFG_DEL $CFG
	xmlstarlet ed -d '/systemList/system[name="atomiswave"]/emulators/emulator[@name="retrorun"]' $CFG > $TMP_CFG_DEL
	rm $CFG
	mv $TMP_CFG_DEL $CFG
fi

if [ -f /storage/.config/emulationstation/scripts/retrorun.sh ]
then
  rm -f /storage/.config/emulationstation/scripts/retrorun.sh
fi

rm -rf ${INSTALL_PATH}
