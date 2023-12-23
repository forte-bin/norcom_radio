#/bin/bash
lsusb -d $1 | sed -nr 's/Bus ([0-9]+) Device ([0-9]+).*/\/dev\/bus\/usb\/\1\/\2/p' -

