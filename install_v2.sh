#!/bin/bash

pre_setup(){
    timedatectl set-timezone Asia/Kolkata
    timedatectl set-ntp true
    timedatectl
    # reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist -c India --download-timeout 50
    pacman -Syy
}

disk_setup(){
    #--------------------------------Disk Selection--------------------------------------
    lsblk
    echo "Enter the disk name(format = /dev/sdx): "
    read disk
    disk="$disk"

    #--------------------------------Disk Formating----------------------------------------
    mkfs.ext4 -F ${disk}

    #--------------------------------Disk Partition----------------------------------------
    echo -e "g\nw" | fdisk $disk
    echo -e "g\nn\n\n\n+500M\nt\n1\nn\n\n\n+100G\nt\n\n23\nn\n\n\n\nt\n\n42\nw" | fdisk $disk
    boot_partition="${disk}1"
    root_partition="${disk}2"
    home_partition="${disk}3"

    #--------------------------------Partition Formating-------------------------------------
    mkfs.fat -F 32 $boot_partition
    mkfs.btrfs -L root $root_partition
    mkfs.ext4 -L home $home_partition

    #--------------------------------Subvolume Creation--------------------------------------
    mount $root_partition /mnt
    btrfs subvolume create /mnt/@root
    btrfs subvolume create /mnt/@snapshots
    umount /mnt

    #--------------------------------Mounting Partition--------------------------------------
    mount -o subvol=@root $root_partition /mnt
    mount --mkdir -o subvol=@snapshots $root_partition /mnt/.snapshots
    mount --mkdir $home_partition /mnt/home
    mount --mkdir $boot_partition /mnt/boot
}

install_packages(){
    pacstrap -K /mnt base
    pacstrap -K /mnt btrfs-progs
    pacstrap -K /mnt dosfstools
    pacstrap -K /mnt linux
    pacstrap -K /mnt linux-firmware
    pacstrap -K /mnt linux-headers
    pacstrap -K /mnt base-devel
    pacstrap -K /mnt networkmanager
}

configure_system(){
    #Genrating fstab file
    genfstab -U /mnt >> /mnt/etc/fstab

    #Setting up timezone and locale
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
    arch-chroot /mnt hwclock --systohc --utc
    echo en_US.UTF-8 UTF-8 > /mnt/etc/locale.gen
    arch-chroot /mnt locale-gen
    touch /mnt/etc/locale.conf
    echo LANG=en_US.UTF-8 > /mnt/etc/locale.conf

    #Setting up root password
    echo "Enter root password: "
    read rp
    rp="$rp"
    echo -e "${rp}\n${rp}\n" | arch-chroot /mnt passwd

    #Installing bootloader
    arch-chroot /mnt bootctl --path=/boot install
    echo -e "timeout 0\ndefault arch-*" > /mnt/boot/loader/loader.conf
    echo -e "title\tArch Linux\nlinux\t/vmlinuz-linux\ninitrd\t/initramfs-linux.img\noptions\troot=${root_partition} rootflags=subvol=@root rw" > /mnt/boot/loader/entries/arch.conf

    #Creating user(adeed)
    arch-chroot /mnt useradd -m -G wheel adeed
    echo "Enter user password: "
    read up
    up="$up"
    echo -e "${up}\n${up}\n" | arch-chroot /mnt passwd adeed
    echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /mnt/etc/sudoers

    #Editing mkinitcpio.conf for btrfs support
    echo -e "MODULES=(btrfs)\nBINARIES=()\nFILES=()\nHOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block btrfs filesystems fsck)" > /mnt/etc/mkinitcpio.conf
    arch-chroot /mnt mkinitcpio -P
}

pre_setup
disk_setup
install_packages
configure_system
