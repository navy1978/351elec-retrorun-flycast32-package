#!/bin/bash
# rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
# touch /dev/input/by-path/platform-odroidgo2-joypad-event-joystick 
echo starting retrorun emulator...
rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
/storage/retrorun/armhf/apps/rg351p-js2xbox --silent -t oga_joypad &
sleep 1
ln -s /dev/input/event3 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
chmod 777 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
sleep 1
echo starting game... "$1"
sleep 1
LD_LIBRARY_PATH=/usr/lib32:/storage/retrorun/armhf/lib:/storage/retrorun/armhf/lib/retrorun /storage/retrorun/armhf/apps/retrorun32 --triggers -n -s /storage/retrorun/armhf/logs -d /roms/bios /storage/retrorun/armhf/core/flycast32_rumble_libretro.so "$1"
sleep 1
kill $(pidof rg351p-js2xbox)
echo end!
# rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick

