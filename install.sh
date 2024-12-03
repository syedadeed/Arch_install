#!/bin/bash

pre_setup ()
{
    timedatectl set-timezone Asia/Kolkata
    timedatectl set-ntp true
    timedatectl
    reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist -c India --download-timeout 50
    pacman -Syy
}

disk_setup ()
{
    #--------------------------------Disk Selection--------------------------------------
    lsblk
    echo "Enter the disk name(format = /dev/sdx): "
    read disk
    disk="$disk"

    #--------------------------------Disk Formating----------------------------------------
    mkfs.ext4 -F ${disk}

    #--------------------------------Disk Partition----------------------------------------
    echo -e "g\nw" | fdisk $disk
    echo -e "g\nn\n\n\n+500M\nt\n1\nn\n\n\n\nt\n\n44\nw" | fdisk $disk

    partition1="${disk}1"
    partition2="${disk}2"

    #--------------------------------Partition2 setup----------------------------------------
    modprobe dm_mod

    #Initializing partition2 for lvm
    pvcreate $partition2

    #Creating volume group(arch)
    vgcreate arch $partition2

    #Creating logical volumes(system, home)
    lvcreate -L 100G arch -n system
    lvcreate -l 100%FREE arch -n home
 
    #Activating logical volumes
    vgchange -ay

    #Formating logical volumes
    mkfs.btrfs -L system /dev/arch/system
    mkfs.ext4 -L home /dev/arch/home

    #Creating subvolumes(system, snapshots) for logical volume "system"
    mount /dev/arch/system /mnt
    btrfs subvolume create /mnt/@system
    btrfs subvolume create /mnt/@snapshots
    umount /mnt

    #Mounting subvolumes(system, snapshots) of logical volume "system"
    mount -o subvol=@system /dev/arch/system /mnt
    mount --mkdir -o subvol=@snapshots /dev/arch/system /mnt/.snapshots

    #Mounting logical volume "home"
    mount --mkdir /dev/arch/home /mnt/home

    #--------------------------------Partition1 setup----------------------------------------
    #Formating(fat32) partition1
    mkfs.fat -F 32 $partition1

    #Mounting partition1
    mount --mkdir $partition1 /mnt/boot
}

install_packages ()
{
    pacstrap -K /mnt base
    pacstrap -K /mnt btrfs-progs
    pacstrap -K /mnt dosfstools
    pacstrap -K /mnt linux
    pacstrap -K /mnt linux-firmware
    pacstrap -K /mnt linux-headers
    pacstrap -K /mnt lvm2
    pacstrap -K /mnt base-devel
    pacstrap -K /mnt intel-ucode
    pacstrap -K /mnt networkmanager
    pacstrap -K /mnt bash-completion
    pacstrap -K /mnt man-db
    pacstrap -K /mnt man-pages
}

configure_system ()
{
    #Genrating fstab file
    genfstab -U /mnt >> /mnt/etc/fstab

    #Setting up timezone and locale
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
    arch-chroot /mnt hwclock --systohc --utc
    echo en_US.UTF-8 UTF-8 > /mnt/etc/locale.gen
    arch-chroot /mnt locale-gen

    #Setting up root password
    echo "Enter root password: "
    read rp
    rp="$rp"
    echo -e "${rp}\n${rp}\n" | arch-chroot /mnt passwd

    #Installing bootloader
    arch-chroot /mnt bootctl --path=/boot install
    echo -e "timeout 0\ndefault arch-*" > /mnt/boot/loader/loader.conf
    echo -e "title\tArch Linux\nlinux\t/vmlinuz-linux\ninitrd\t/initramfs-linux.img\noptions\troot=/dev/mapper/arch-system rootflags=subvol=@system rw" > /mnt/boot/loader/entries/arch.conf

    #Creating user(adeed)
    arch-chroot /mnt useradd -m -G wheel adeed
    echo "Enter user password: "
    read up
    up="$up"
    echo -e "${up}\n${up}\n" | arch-chroot /mnt passwd adeed
    echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /mnt/etc/sudoers

    #Editing mkinitcpio.conf for lvm and btrfs support
    echo -e "MODULES=(btrfs)\nBINARIES=()\nFILES=()\nHOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block lvm2 btrfs filesystems fsck)" > /mnt/etc/mkinitcpio.conf
    arch-chroot /mnt mkinitcpio -P
}
pre_setup
disk_setup
install_packages
configure_system
