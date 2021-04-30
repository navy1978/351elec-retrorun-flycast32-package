#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
# Load functions needed to send messages to the console
. /etc/profile

unset MYARCH
MYARCH="armhf"
LINK="https://github.com/navy1978/351elec-retrorun-flycast32-package/raw/main/packages/retrorun.tar.gz"
SHASUM="4858904a6e7e3ba36cd266c707ce6bd0394d53a63626bfb02cd7e1a911609d"

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
echo 'file can be found in:' $LINKDEST  'checking sha256sum'
CHECKSUM=$(sha256sum $LINKDEST | awk '{print $1}')
if [ ! "${SHASUM}" == "${CHECKSUM}" ]
then
  rm "${LINKDEST}"
  echo 'checksum failed !'
  echo 'should be:' $SHASUM
  echo 'but it is:'$(sha256sum $LINKDEST)
  exit 1
fi
echo 'checksum valid'
echo 'decompressing package...'
tar xvf $LINKDEST -C "${INSTALL_PATH}/${MYARCH}/"
rm $LINKDEST

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

echo 'Adding retrorun_flycast32 to systems list for dreamcast'
xmlstarlet ed --subnode "/systemList/system[name='dreamcast']/emulators" --type elem -n emulator -v "" $CFG | xmlstarlet ed --insert "/systemList/system[name='dreamcast']/emulators/emulator[not(@name)]" --type attr -n name -v retrorun > $TMP_CFG_ADD1
xmlstarlet ed --subnode "/systemList/system[name='dreamcast']/emulators/emulator[@name='retrorun']" --type elem -n cores -v "" $TMP_CFG_ADD1 > $TMP_CFG_ADD2
xmlstarlet ed --subnode "/systemList/system[name='dreamcast']/emulators/emulator[@name='retrorun']/cores" --type elem -n core -v "flycast" $TMP_CFG_ADD2 | xmlstarlet ed --insert "/systemList/system[name='dreamcast']/emulators/emulator[@name='retrorun']/cores/core" --type attr -n default -v true > $TMP_CFG_ADD3
rm $CFG
rm $TMP_CFG_ADD1
rm $TMP_CFG_ADD2
mv $TMP_CFG_ADD3 $CFG

echo 'Adding retrorun_flycast32 to systems list for naomi'
xmlstarlet ed --subnode "/systemList/system[name='naomi']/emulators" --type elem -n emulator -v "" $CFG | xmlstarlet ed --insert "/systemList/system[name='naomi']/emulators/emulator[not(@name)]" --type attr -n name -v retrorun > $TMP_CFG_ADD1
xmlstarlet ed --subnode "/systemList/system[name='naomi']/emulators/emulator[@name='retrorun']" --type elem -n cores -v "" $TMP_CFG_ADD1 > $TMP_CFG_ADD2
xmlstarlet ed --subnode "/systemList/system[name='naomi']/emulators/emulator[@name='retrorun']/cores" --type elem -n core -v "flycast" $TMP_CFG_ADD2 | xmlstarlet ed --insert "/systemList/system[name='naomi']/emulators/emulator[@name='retrorun']/cores/core" --type attr -n default -v true > $TMP_CFG_ADD3
rm $CFG
rm $TMP_CFG_ADD1
rm $TMP_CFG_ADD2
mv $TMP_CFG_ADD3 $CFG

echo 'Adding retrorun_flycast32 to systems list for atomiswave'
xmlstarlet ed --subnode "/systemList/system[name='atomiswave']/emulators" --type elem -n emulator -v "" $CFG | xmlstarlet ed --insert "/systemList/system[name='atomiswave']/emulators/emulator[not(@name)]" --type attr -n name -v retrorun > $TMP_CFG_ADD1
xmlstarlet ed --subnode "/systemList/system[name='atomiswave']/emulators/emulator[@name='retrorun']" --type elem -n cores -v "" $TMP_CFG_ADD1 > $TMP_CFG_ADD2
xmlstarlet ed --subnode "/systemList/system[name='atomiswave']/emulators/emulator[@name='retrorun']/cores" --type elem -n core -v "flycast" $TMP_CFG_ADD2 | xmlstarlet ed --insert "/systemList/system[name='atomiswave']/emulators/emulator[@name='retrorun']/cores/core" --type attr -n default -v true > $TMP_CFG_ADD3
rm $CFG
rm $TMP_CFG_ADD1
rm $TMP_CFG_ADD2
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

