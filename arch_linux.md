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

## wheel Group

The `wheel` group is a special Unix/Linux group for administrative users. Historically named after the "big wheel" (important person) concept.

**Purpose:**
- Controls who can use `su` to become root
- Controls who gets sudo privileges
- Acts as a security layer - only trusted users are added to wheel

## sudo (Superuser Do)

`sudo` allows regular users to execute commands as root without knowing the root password.

**How it works:**
1. User runs `sudo command`
2. System checks `/etc/sudoers` file
3. If user/group has permission, prompts for *user's* password (not root's)
4. Executes command as root

**Key sudoers rules:**
```
%wheel ALL=(ALL:ALL) ALL
```
- `%wheel` = members of wheel group
- First `ALL` = from any host
- `(ALL:ALL)` = can run as any user:group
- Last `ALL` = can run any command

## Why This Design?

**Security benefits:**
- Root password stays secret
- Individual accountability (logs show which user ran what)
- Granular permissions (can limit which commands)
- Easy to revoke access (remove from wheel group)

**Common alternative:**
```
username ALL=(ALL:ALL) ALL
```
Gives sudo access to specific user without wheel group.

## Practical Flow

1. Add user to wheel: `usermod -aG wheel username`
2. Configure sudoers: `%wheel ALL=(ALL:ALL) ALL`
3. User can now: `sudo pacman -S package`
4. System prompts for user's password, not root's

This separation keeps the root account secure while allowing administrative tasks.
