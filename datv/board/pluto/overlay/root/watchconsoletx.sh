#!/bin/sh
#https://www.analog.com/media/cn/technical-documentation/user-guides/AD9364_Register_Map_Reference_Manual_UG-672.pdf

adphys="$(cat /sys/bus/iio/devices/iio:device0/name)"

ptton()
{
    #PTT on GPIO 0 AND GPIO 2 (GPIO 1 should be not touched)
    if [ "$adphys" = "ad9361-phy" ] ; then
	echo 0x27 0x50 > /sys/kernel/debug/iio/iio:device0/direct_reg_access
    else
    echo 0x27 0x50 > /sys/kernel/debug/iio/iio:device1/direct_reg_access
    fi
	echo 1 > /sys/class/gpio/gpio906/value
}

pttoff()
{
    if [ "$adphys" = "ad9361-phy" ] ; then
	    echo 0x27 0x00 > /sys/kernel/debug/iio/iio:device0/direct_reg_access
    else
        echo 0x27 0x00 > /sys/kernel/debug/iio/iio:device1/direct_reg_access
    fi
		echo 0 > /sys/class/gpio/gpio906/value
}


if [ "$adphys" = "ad9361-phy" ] ; then
echo manual_tx_quad > /sys/bus/iio/devices/iio:device0/calib_mode
#Manual GPIO
echo 0x26 0x10 > /sys/kernel/debug/iio/iio:device0/direct_reg_access
else
echo manual_tx_quad > /sys/bus/iio/devices/iio:device1/calib_mode
#Manual GPIO
echo 0x26 0x10 > /sys/kernel/debug/iio/iio:device1/direct_reg_access
fi
#MIO for plutoplus : MIO start at 906, EMIO at 960
echo "906" > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio906/direction

pttoff

loop()
{
while :
do
if [ "$adphys" = "ad9361-phy" ] ; then
inotifywait -e modify /sys/bus/iio/devices/iio:device0/out_altvoltage1_TX_LO_powerdown
txmute=$(cat /sys/bus/iio/devices/iio:device0/out_altvoltage1_TX_LO_powerdown)
else
inotifywait -e modify /sys/bus/iio/devices/iio:device1/out_altvoltage1_TX_LO_powerdown
txmute=$(cat /sys/bus/iio/devices/iio:device1/out_altvoltage1_TX_LO_powerdown)
fi
if [ "$txmute" = "1" ] ; then
echo "SdrConsole PTT OFF"
pttoff
else
       
   echo "SdrConsole PTT ON"
   ptton   
fi
done
}

loop
