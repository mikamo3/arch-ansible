# GUI Role

GUI環境の統合管理ロール。インベントリ設定に基づいて適切なデスクトップ環境、プロトコル、ディスプレイマネージャーを自動選択・インストールする。

## 対応環境

### デスクトップ環境
- **Hyprland** - モダンなWaylandコンポジター
- **i3** - 軽量なタイル型ウィンドウマネージャー（X11）
- **Sway** - i3のWayland版
- **GNOME** - フル機能のデスクトップ環境（Wayland）

### プロトコル
- **Wayland** - モダンなディスプレイプロトコル（Hyprland, Sway）
- **Xorg** - 従来のディスプレイサーバー（i3）

### ディスプレイマネージャー
- **Ly** - 軽量でモダンなログインマネージャー
- **LightDM** - 機能豊富で安定したログインマネージャー
- **GDM** - GNOME標準のディスプレイマネージャー

## インベントリ設定

### 基本設定
```yaml
gui:
  desktop: hyprland      # hyprland, i3, sway, gnome (protocol auto-detected)
  display_manager: ly    # ly, lightdm, gdm
  fonts:
    install: minimal     # minimal, full
    enable_japanese: true
    enable_emoji: true
  inputmethod:
    enable: true
    method: fcitx5
```

### 設定例

#### モダン環境（Hyprland + Wayland）
```yaml
gui:
  desktop: hyprland
  display_manager: ly
```

#### 安定環境（i3 + Xorg）  
```yaml
gui:
  desktop: i3
  display_manager: lightdm
```

#### 軽量環境（Sway + Wayland）
```yaml
gui:
  desktop: sway
  display_manager: ly
```

#### デスクトップ環境（GNOME + Wayland）
```yaml
gui:
  desktop: gnome
  display_manager: gdm
```

#### 最小フォント構成（テスト・軽量環境）
```yaml
gui:
  desktop: hyprland
  fonts:
    install: minimal     # 日本語 + 固定幅フォントのみ
```

#### フルフォント構成（開発・デザイン環境）
```yaml
gui:
  desktop: hyprland
  fonts:
    install: full        # プログラミング・デザインフォント含む
```

## 自動選択ルール

### プロトコル自動選択
- **Hyprland, Sway, GNOME** → Wayland（自動）
- **i3** → Xorg（自動）

### 推奨組み合わせ
- **Wayland環境** → Ly（モダン、軽量）
- **Xorg環境** → LightDM（安定、機能豊富）
- **GNOME環境** → GDM（標準、最適化）

## コンポーネント構成

### 共通コンポーネント (`gui/common`)
- フォント（日本語、絵文字対応）
- アイコンテーマ
- 入力メソッド（fcitx5）
- GUI基本ユーティリティ

### プロトコル固有 (`gui/wayland`, `gui/xorg`)
- Waylandコンポジター用パッケージ
- Xorgサーバー・ドライバー

### デスクトップ環境固有
- 各環境専用のパッケージ・設定

## フォント構成

### Minimal フォント（`install: minimal`）
- **Noto Fonts** - 基本ラテン文字フォント
- **Noto Fonts CJK** - 日本語・中国語・韓国語サポート
- **Noto Fonts Emoji** - 基本絵文字サポート
- **DejaVu** - システム標準の固定幅フォント
- **FontConfig** - フォント設定システム

**用途**: テスト環境、軽量システム、最小限のGUI

### Full フォント（`install: full`）
Minimalに加えて以下を追加：

**プログラミング用フォント:**
- **Cica** - 日本語対応プログラミングフォント
- **PlemolJP** - 美しい日本語プログラミングフォント
- **IBM Plex** - IBMのモダンフォントファミリー

**デザイン用フォント:**
- **Bizter** - ビジネス用途フォント
- **Line Seed** - Line社のオープンソースフォント

**管理ツール:**
- **Gucharmap** - 文字マップ
- **Font Manager** - フォント管理GUI

**用途**: 開発環境、デザイン作業、デスクトップ利用

## タグ使用例

```bash
# GUI環境全体
ansible-playbook playbook.yml --tags gui

# 共通コンポーネントのみ
ansible-playbook playbook.yml --tags gui-common

# 特定デスクトップ環境のみ
ansible-playbook playbook.yml --tags gui-hyprland
ansible-playbook playbook.yml --tags gui-i3

# ディスプレイマネージャーのみ
ansible-playbook playbook.yml --tags gui-ly
```

## 利点

1. **柔軟性**: インベントリで簡単に環境切り替え
2. **保守性**: 各コンポーネントの責任分離
3. **再利用性**: 共通部分の抽象化
4. **拡張性**: 新しい環境・マネージャーの追加が容易

## 注意事項

1. **プロトコル互換性**: デスクトップ環境とプロトコルの組み合わせは自動選択
2. **設定の競合**: 異なるディスプレイマネージャーを同時使用しないこと
3. **再起動必要**: GUI環境変更後は再起動推奨
