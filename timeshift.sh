#!/bin/bash

create() {
    local snapshot_name="$1"
    sudo btrfs subvolume snapshot / /.snapshots/"$snapshot_name"
    sudo cp /boot/loader/entries/arch.conf /boot/loader/entries/"${snapshot_name}.conf"
    sudo sed -i "s/@system/@snapshots\/${snapshot_name}/g" /boot/loader/entries/"${snapshot_name}.conf"
}

restore() {
    sudo mount /dev/arch/system /mnt
    sudo rm -rf /mnt/@system/*
    sudo btrfs subvolume delete /mnt/@system
    sudo btrfs subvolume snapshot / /mnt/@system
}

maintainance(){
    sudo btrfs balance start --full-balance /
    sudo btrfs filesystem defragment -r /
    sudo btrfs scrub start /
}

if [[ "$1" == "-c" ]]; then
    create "$2"
elif [[ "$1" == "-r" ]]; then
    restore
elif [[ "$1" == "-m" ]]; then
    maintainance
else
    echo "Usage: $0 {-c snapshot_name | -r | -m}"
    exit 1
fi
