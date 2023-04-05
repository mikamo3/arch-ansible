#!/usr/bin/env bash
pacman -Syu
pacman -S python sudo
useradd -m -u 2000 -s /bin/bash ansible
usermod -aG wheel ansible
echo "set ansible password"
passwd ansible
echo "ansible   ALL=(ALL) ALL" >> /etc/sudoers