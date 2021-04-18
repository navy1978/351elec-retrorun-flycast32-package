#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
# Load functions needed to send messages to the console
. /etc/profile

unset MYARCH
MYARCH="armhf"
LINK="https://github.com/navy1978/351elec-retrorun-flycast32-package/tree/main/packages/retrorun_flycast32.tar.gz"
SHASUM="031db70f0f4c7d0ed1f936ddb7059f7b14dec3ca8869b9bb8fb609ac594f4b49"

INSTALL_PATH="/storage/retrorun_flycast32"
BINARY="retrorun_flycast32"
LINKDEST="${INSTALL_PATH}/${MYARCH}/retrorun_flycast32.tar.gz"
CFG="/storage/.emulationstation/es_systems.cfg"
TMP_CFG_DEL="/storage/.emulationstation/es_systems_del.cfg"
TMP_CFG_ADD1="/storage/.emulationstation/es_systems_tmp1.cfg"
TMP_CFG_ADD2="/storage/.emulationstation/es_systems_tmp2.cfg"
TMP_CFG_ADD3="/storage/.emulationstation/es_systems_tmp3.cfg"
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

if grep -q 'retrorun' "$CFG"
then
	xmlstarlet ed -d '/systemList/system[name="dreamcast"]/emulators/emulator[@name="retrorun"]' $CFG > $TMP_CFG_DEL
	rm CFG
	mv $TMP_CFG_DEL $CFG
fi

	echo 'Adding retrorun_flycast32 to systems list'
	echo 'Adding emulator...'
	xmlstarlet ed --subnode "/systemList/system[name='dreamcast']/emulators" --type elem -n emulator -v "" $CFG | xmlstarlet ed --insert "/systemList/system[name='dreamcast']/emulators/emulator[not(@name)]" --type attr -n name -v retrorun > $TMP_CFG_ADD1
	xmlstarlet ed --subnode "/*/*/*/emulator[@name='retrorun']" --type elem -n cores -v "" $TMP_CFG_ADD1 > $TMP_CFG_ADD2
	xmlstarlet ed --subnode "/*/*/*/emulator[@name='retrorun']/cores" --type elem -n core -v "flycast" $TMP_CFG_ADD2 | xmlstarlet ed --insert "/*/*/*/emulator[@name='retrorun']/cores/core" --type attr -n default -v true > $TMP_CFG_ADD3
rm CFG
rm TMP_CFG_ADD1
rm TMP_CFG_ADD2
mv $TMP_CFG_ADD3 $CFG


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
