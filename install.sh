# Empty if not nvme, p if nvme
drive_postfix=""
hostname="arch-btw"
lang="en_US.UTF-8"
user="cruizk"

# Check if the drive is nvme
if [[ $1 == *"nvme"* ]]; then
  drive_postfix="p"
fi

timedatectl set-ntp true

# Wipe and partition drive
wipefs -a $1
sfdisk $1 < disks.part

efi="${1}${drive_postfix}1"
swap="${1}${drive_postfix}2"
filesystem="${1}${drive_postfix}3"

# Format partitions
mkfs.fat -F32 $efi
mkfs.ext4 $filesystem
mkswap $swap

mount $filesystem /mnt
swapon $swap

# Reflector
pacman -Syy
pacman -S --noconfirm reflector
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector -c "US" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist

# Install
pacstrap /mnt base base-devel linux linux-firmware nano vim dhcpcd sudo

genfstab -U -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt
printf "$hostname\n" > /etc/hostname

printf "127.0.0.1 localhost\n::1 localhost\n127.0.0.1 ${hostname}.localdomain ${hostname}\n"

# Locale 
timedatectl set-timezone America/Chicago

printf "en_US.UTF-8 UTF-8\nen_US ISO-8859-1\n" > /etc/locale.gen

locale-gen
printf "LANG=$lang" > /etc/locale.conf
export LANG=$lang

printf "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" >> /etc/pacman.conf

# Time
ln -s /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc

# User setup
echo "Root Password"
passwd
useradd -mg users -G wheel,storage,power -s /bin/bash $user
echo "User Password"
passwd $user

# Add wheel to sudoers file
echo '%wheel ALL=(ALL) ALL' | EDITOR='tee -a' visudo


# Grub install
pacman -Sy
pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
mkdir /boot/efi
mount $efi /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg