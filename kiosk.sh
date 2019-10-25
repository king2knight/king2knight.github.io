#!/bin/bash
#set screen saver to not blank screen, disable it, disable power management
xset s noblank
xset s off
xset -dpms

#Remove mouse after idle time
unclutter -idle 0.5 -root &

#Remove mouse instantly
#unclutter -root &

#Edit Chromium values in place (resets with reboot)
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/pi/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/pi/.config/chromium/Default/Preferences

#Launch Chromium in kiosk mode
/usr/bin/chromium-browser --noerrdialogs --disable-infobars --kiosk file:///home/pi/Site/index.html &

#swap tabs in 10 second loop
#while true; do
#   xdotool keydown ctrl+Tab; xdotool keyup ctrl+Tab;
#   sleep 10
#done
