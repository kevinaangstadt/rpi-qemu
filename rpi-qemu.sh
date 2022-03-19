#!/bin/bash

IMG=2020-12-02-raspios-buster-armhf-lite.img
MACHINE=raspi3b


SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )


# check if the source image exists yet
if [ ! -f "$DIR/$IMG" ]; then 
    echo "Could not find OS image.  Did you run \`qeumu-setup.sh\`?"
    exit 1
fi

if [ -z "$1" ]; then
    echo "You must specify a path to share with the vm as the first argument"
    exit 1
fi

set -x

qemu-system-aarch64 \
  -M $MACHINE \
  -append "rw earlyprintk loglevel=8 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1" \
  -dtb $DIR/bcm2710-rpi-3-b-plus.dtb \
  -drive file=$DIR/$IMG,if=sd,format=raw \
  -kernel $DIR/kernel8.img \
  -no-reboot \
  -m 1G \
  -smp 4 \
  -serial stdio \
  -display none \
  -usb \
  -device usb-mouse \
  -device usb-kbd \
  -device usb-net,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::5555-:22,smb=$1 