# Installing yay for AUR packages
git clone https://aur.archlinux.org/yay.git ~/yay
cd ~/yay
makepkg -si

# Installing packages
pacman -S xorg-server
# Nvidia
pacman -S Nvidia
# AMD
# pacman -S xf86-video-amdgpu
pacman -S firefox