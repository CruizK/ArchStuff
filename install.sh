# Empty if not nvme, p if nvme
drive_postfix=""



if [ $# -eq 0 ]; then
  echo "./install.sh <drive_to_use>"
  exit 1
fi

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

cp second.sh /mnt/second.sh
chmod +x /mnt/second.sh
arch-chroot /mnt ./second.sh $efi
rm /mnt/second.sh