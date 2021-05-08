#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later

# Load functions needed to send messages to the console
. /etc/profile


INSTALL_PATH="/storage/retrorun"
BINARY="retrorun"
CFG_DIR="/storage/.config/emulationstation/"
START_SCRIPT="$BINARY.sh"

MYARCH="armhf"
echo 'deleting config files for dreamcast naomi and atomiswave'
rm ${CFG_DIR}es_systems_dreamcast.cfg
rm ${CFG_DIR}es_systems_naomi.cfg
rm ${CFG_DIR}es_systems_atomiswave.cfg



rm -rf ${INSTALL_PATH}
