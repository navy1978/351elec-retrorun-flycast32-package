#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
# Load functions needed to send messages to the console
. /etc/profile

unset MYARCH
MYARCH="armhf"
LINK="https://github.com/navy1978/351elec-retrorun-flycast32-package/raw/main/packages/retrorun.tar.gz"
SHASUM="6a1e3985f3a30b9ad2d3a3e50b7e684a40857c9a87f9c702dda6fceda7be70ef"

INSTALL_PATH="/storage/retrorun"
BINARY="retrorun"
LINKDEST="${INSTALL_PATH}/retrorun.tar.gz"
CFG_DIR="/storage/.config/emulationstation/"

START_SCRIPT="$BINARY.sh"

mkdir -p "${INSTALL_PATH}/"

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
tar xvf $LINKDEST -C "${INSTALL_PATH}/"
rm $LINKDEST

cp es_systems_atomiswave.cfg $CFG_DIR
cp es_systems_naomi.cfg $CFG_DIR
cp es_systems_dreamcast.cfg $CFG_DIR



read -d '' content <<EOF
#!/bin/bash
source /etc/profile
BINPATH="/usr/bin"
EXECLOG="/tmp/logs/exec.log"
cd ${INSTALL_PATH}/retrorun/
# we need to create this file for the input (joypad):
touch /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
maxperf
./retrorun_flycast32 "\$1" >> \$EXECLOG 2>&1
normperf
EOF
echo "$content" > ${INSTALL_PATH}/${START_SCRIPT}
chmod +x ${INSTALL_PATH}/${START_SCRIPT}

