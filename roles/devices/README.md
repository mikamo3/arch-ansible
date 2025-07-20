# Devices Role

ハードウェア固有のデバイスドライバーとサービスの設定を行うロール。

## 設定可能な項目

### Graphics (グラフィック)
```yaml
graphics:
  driver: intel        # ドライバーの種類
  hw_accel: true      # ハードウェアアクセラレーション
  cuda_support: false # NVIDIA CUDA サポート（nvidia のみ）
```

**対応ドライバー:**
- `default`: 自動検出（デフォルト）
- `intel`: Intel 統合グラフィック
- `amd`: AMD グラフィック
- `nvidia`: NVIDIA グラフィック
- `virtio`: 仮想マシン用
- `none`: グラフィックドライバーなし

### Bluetooth
```yaml
bluetooth:
  enable: true  # Bluetooth サポート
```

### Printer/Scanner (プリンター/スキャナー)
```yaml
printer:
  enable: true  # CUPS プリンターサポート
```

### Sound (音声)
```yaml
sound:
  enable: true  # PipeWire 音声システム
```

## インベントリ設定例

### デスクトップPC (NVIDIA GPU)
```yaml
vars:
  graphics:
    driver: nvidia
    cuda_support: true
    hw_accel: true
  bluetooth:
    enable: true
  printer:
    enable: true
  sound:
    enable: true
```

### ラップトップ (Intel GPU)
```yaml
vars:
  graphics:
    driver: intel
    hw_accel: true
  bluetooth:
    enable: true
  printer:
    enable: true
  sound:
    enable: true
```

### サーバー (ヘッドレス)
```yaml
vars:
  graphics:
    driver: none
  bluetooth:
    enable: false
  printer:
    enable: false
  sound:
    enable: false
```

### 仮想マシン
```yaml
vars:
  graphics:
    driver: virtio
    hw_accel: false
  bluetooth:
    enable: false
  printer:
    enable: false
  sound:
    enable: true
```

## タグ

個別のコンポーネントのみ実行したい場合：

```bash
# グラフィックドライバーのみ
ansible-playbook -i inventory playbook.yml --tags graphics

# 音声設定のみ  
ansible-playbook -i inventory playbook.yml --tags sound

# Bluetoothのみ
ansible-playbook -i inventory playbook.yml --tags bluetooth

# プリンター設定のみ
ansible-playbook -i inventory playbook.yml --tags printer
```

## インストールされるパッケージ

### Graphics
- **共通**: mesa, mesa-utils, libva-utils, vdpauinfo
- **Intel**: intel-media-driver, vulkan-intel
- **AMD**: vulkan-radeon, libva-mesa-driver
- **NVIDIA**: nvidia-dkms, nvidia-utils, nvidia-settings
- **Virtio**: xf86-video-qxl

### Audio (PipeWire)
- **コア**: pipewire, wireplumber, pipewire-pulse, pipewire-alsa, pipewire-jack
- **GUI**: helvum (AUR)

### Bluetooth
- **コア**: bluez, bluez-utils, blueman
- **GUI**: overskride (AUR)

### Printer/Scanner
- **プリンター**: cups, gutenprint
- **スキャナー**: sane, simple-scan
