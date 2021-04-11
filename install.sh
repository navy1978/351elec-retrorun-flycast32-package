#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
# Load functions needed to send messages to the console
. /etc/profile

unset MYARCH
MYARCH="armhf"
LINK="https://github.com/navy1978/351elec-retrorun-flycast32-package/tree/main/packages"
SHASUM="031db70f0f4c7d0ed1f936ddb7059f7b14dec3ca8869b9bb8fb609ac594f4b49"

INSTALL_PATH="/storage/retrorun_flycast32"
BINARY="retrorun_flycast32"
LINKDEST="${INSTALL_PATH}/${MYARCH}/drastic.tar.gz"
CFG="/storage/.emulationstation/es_systems.cfg"
START_SCRIPT="$BINARY.sh"

mkdir -p "${INSTALL_PATH}/${MYARCH}/"

curl -Lo $LINKDEST $LINK
CHECKSUM=$(sha256sum $LINKDEST | awk '{print $1}')
if [ ! "${SHASUM}" == "${CHECKSUM}" ]
then
  rm "${LINKDEST}"
  exit 1
fi

tar xvf $LINKDEST -C "${INSTALL_PATH}/${MYARCH}/"
rm $LINKDEST

if grep -q '<name>dreamcast</name>' "$CFG"
then
	xmlstarlet ed -L -P -d "/systemList/system[name='dreamcast']" $CFG
fi

	echo 'Adding retrorun_flycast32 to systems list'
	xmlstarlet ed --omit-decl --inplace \
		-s '//systemList' -t elem -n 'system' \
		-s '//systemList/system[last()]' -t elem -n 'name' -v 'dreamcast'\
		-s '//systemList/system[last()]' -t elem -n 'fullname' -v 'Sega Dreamcast'\
		-s '//systemList/system[last()]' -t elem -n 'path' -v '/storage/roms/dreamcast'\
		-s '//systemList/system[last()]' -t elem -n 'manufacturer' -v 'Sega'\
		-s '//systemList/system[last()]' -t elem -n 'release' -v '1998'\
		-s '//systemList/system[last()]' -t elem -n 'hardware' -v 'console'\
		-s '//systemList/system[last()]' -t elem -n 'extension' -v '.cdi .CDI .gdi .GDI .chd .CHD .zip .ZIP .7z .7Z'\
		-s '//systemList/system[last()]' -t elem -n 'command' -v "/storage/retrorun_flycast32/$START_SCRIPT %ROM%"\
		-s '//systemList/system[last()]' -t elem -n 'platform' -v 'dreamcast'\
		-s '//systemList/system[last()]' -t elem -n 'theme' -v 'dreamcast'\
		$CFG

read -d '' content <<EOF
#!/bin/bash
source /etc/profile
BINPATH="/usr/bin"
EXECLOG="/tmp/logs/exec.log"
cd ${INSTALL_PATH}/${MYARCH}/retrorun_flycast32/
# we need to create this file for the input (joypad):
touch /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
maxperf
./retrorun_flycast32 "\$1" >> \$EXECLOG 2>&1
normperf
EOF
echo "$content" > ${INSTALL_PATH}/${START_SCRIPT}
chmod +x ${INSTALL_PATH}/${START_SCRIPT}
if [ ! -d "${INSTALL_PATH}/${MYARCH}/retrorun_flycast32/config" ]
then
  mkdir ${INSTALL_PATH}/${MYARCH}/retrorun_flycast32/config
fi
cp retrorun_flycast32/retrorun_flycast32.cfg ${INSTALL_PATH}/${MYARCH}/retrorun_flycast32/config 2>/dev/null ||:

### 1.0 compatibility
if [ -f "/storage/.config/emuelec/scripts/retrorun_flycast32.sh" ]
then
  rm -f "/storage/.config/emuelec/scripts/retrorun_flycast32.sh"
fi

### Only link on 1.0 as 2.0 paths are different.
if [ -d "/storage/.config/emuelec/scripts" ]
then
  ln -sf ${INSTALL_PATH}/${START_SCRIPT} /storage/.config/emuelec/scripts/retrorun_flycast32.sh
fi
