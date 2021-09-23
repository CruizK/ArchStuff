# Installing yay for AUR packages
git clone https://aur.archlinux.org/yay.git ~/yay
cd ~/yay
makepkg -si

# Installing packages
pacman -S xorg
pacman -S firefox