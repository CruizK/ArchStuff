user="cruizk"
hostname="arch-btw"
lang="en_US.UTF-8"

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
mount $1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg