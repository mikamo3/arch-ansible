
#!/usr/bin/env bash
set -e

# Arch Linux install diskでAnsible実行環境を整えるスクリプト

echo "=== Arch Linux Ansible Setup Script ==="

# ネットワーク接続確認
echo "Checking network connectivity..."
if ! ping -c 1 archlinux.org &> /dev/null; then
    echo "Error: No network connectivity. Please configure network first."
    exit 1
fi

# パッケージデータベース更新
echo "Updating package database..."
pacman -Sy --noconfirm

# 必要なパッケージのインストール
echo "Installing required packages..."
pacman -S --noconfirm \
    python \
    sudo \
    openssh \
    dosfstools \
    btrfs-progs \
    gptfdisk

# wheelグループにsudo権限付与
echo "Configuring sudo for wheel group..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# ansibleユーザー作成
echo "Creating ansible user..."
if ! id ansible &> /dev/null; then
    useradd -m -s /bin/bash ansible
    usermod -aG wheel ansible
    echo "Please set password for ansible user:"
    passwd ansible
else
    echo "ansible user already exists"
fi


# SSH設定
echo "Configuring SSH..."
systemctl start sshd
systemctl enable sshd

# SSH設定の最適化（必要に応じて）
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

# IP address detection and display
echo "Detecting network configuration..."
NETWORK_INTERFACES=$(ip -4 addr show | grep -E '^[0-9]+:' | awk '{print $2}' | sed 's/://' | grep -v lo)
IP_ADDRESSES=""

for iface in $NETWORK_INTERFACES; do
    IP=$(ip -4 addr show "$iface" 2>/dev/null | grep inet | awk '{print $2}' | cut -d'/' -f1 | head -1)
    if [[ -n "$IP" ]]; then
        IP_ADDRESSES="${IP_ADDRESSES}${iface}: ${IP}\n"
    fi
done

echo ""
echo "=== Setup Complete ==="
echo "You can now connect via SSH and run Ansible playbooks"
echo ""
echo "Available network interfaces:"
echo -e "$IP_ADDRESSES"
echo ""
echo "SSH connection example: ssh ansible@<ip_address>"
echo "Install system command: ./install_system.sh -t <ip_address>"
echo ""