# Arch Linux WSL Post-Installation Setup

## As Root (Initial Setup)

```bash
# 1. Update system
pacman-key --init && pacman-key --populate archlinux
pacman -Syu

# 2. Install essentials
pacman -S sudo nano base-devel git curl

# 3. Create user
useradd -m -G wheel -s /bin/bash nixmachine
passwd nixmachine

# 4. Configure sudo
EDITOR=nano visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL

# 5. Switch to user
su - nixmachine
```

## As nixmachine (Development Setup)

```bash
# 6. Test sudo
sudo whoami  # Should return "root"

# 7. Install Nix
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# 8. Load Nix
. ~/.nix-profile/etc/profile.d/nix.sh
echo '. ~/.nix-profile/etc/profile.d/nix.sh' >> ~/.bashrc

# 9. Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# 10. Test Nix
nix --version
nix-shell -p hello --run hello
```

## Usage Examples

```bash
# Development environments
nix-shell -p python3 nodejs
nix-shell -p rustc cargo go
nix-shell -p python3 python3Packages.pip
```
