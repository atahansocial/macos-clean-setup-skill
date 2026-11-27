#!/usr/bin/env zsh

# Check whether an external mouse (USB, Bluetooth, 2.4GHz Dongle) is connected.
# Built-in MacBook Trackpad reports Transport = "FIFO"; external mice use USB/Bluetooth.
EXTERNAL_MOUSE=$(ioreg -r -c IOHIDDevice -d 1 | awk '
  /^\+-o / { transport=""; usage=""; product="" }
  /"Transport" =/ { transport=$0 }
  /"PrimaryUsage" = 2$/ { usage=2 }
  /"Product" =/ { product=$0 }
  usage == 2 && transport != "" && transport !~ /"FIFO"/ && product !~ /Apple Internal/ {
    found=1; exit
  }
  END { print found ? "1" : "0" }
')

MOS_RUNNING=$(pgrep -x "Mos" >/dev/null && echo "1" || echo "0")

if [[ "$EXTERNAL_MOUSE" == "1" ]]; then
  if [[ "$MOS_RUNNING" == "0" ]]; then
    open -a /Applications/Mos.app
  fi
else
  if [[ "$MOS_RUNNING" == "1" ]]; then
    killall Mos 2>/dev/null
  fi
fi
