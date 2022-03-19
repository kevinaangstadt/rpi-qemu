#!/bin/bash

IMG=2020-12-02-raspios-buster-armhf-lite.img


SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

if [[ $OSTYPE == 'darwin'* ]]; then

    if [ -z "$(which brew)" ]; then
        echo "Install homebrew (https://brew.sh) before continuing"
        exit 1
    fi 
    brew install qemu samba expect

elif [[ $OSTYPE == 'linux'* ]]; then 

    if [ -z "$(which apt)" ]; then 
        echo "This script is only designed to work with apt-based systems"
        exit 1
    fi
    sudo add-apt-repository ppa:savoury1/virtualisation
    sudo apt update
    sudo apt install -y qemu qemu-system-arm curl samba expect

fi

if [ ! -f "$DIR/$IMG" ]; then 
    curl -L -o $DIR/img.zip https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2020-12-04/2020-12-02-raspios-buster-armhf-lite.zip
    unzip $DIR/img.zip -d $DIR 
    rm $DIR/img.zip

    # resize image
    qemu-img resize $DIR/$IMG 2G

    $DIR/pi-setup.exp $DIR $IMG
fi