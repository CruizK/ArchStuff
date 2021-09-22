drive_postfix=""

# Check if the drive is nvme
if [[ $1 == *"nvme"* ]]; then
  drive_postfix="p"
fi

timedatectl set-ntp true
wipefs -a $1
sfdisk $1 < disks.part

efi="${1}${drive_postfix}1"
swap="${1}${drive_postfix}2"
filesystem="${1}${drive_postfix}3"