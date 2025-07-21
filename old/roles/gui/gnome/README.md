# GNOME Role

GNOME デスクトップ環境の設定を行うロール。モダンなWayland環境でフル機能のデスクトップ体験を提供。

## インストールされるパッケージ

### コアGNOME
- **gnome-shell** - GNOMEシェル
- **gnome-session** - セッション管理
- **gnome-settings-daemon** - 設定デーモン
- **gnome-control-center** - 設定アプリケーション
- **gnome-keyring** - パスワード管理
- **mutter** - ウィンドウマネージャー・コンポジター

### 基本アプリケーション
- **nautilus** - ファイルマネージャー
- **gnome-terminal** - ターミナル
- **evince** - ドキュメントビューアー
- **eog** - 画像ビューアー
- **gedit** - テキストエディター
- **gnome-calculator** - 電卓
- **gnome-calendar** - カレンダー
- **gnome-weather** - 天気

### システム統合
- **network-manager-applet** - ネットワーク管理
- **gnome-bluetooth** - Bluetooth統合
- **gvfs** - 仮想ファイルシステム
- **xdg-user-dirs-gtk** - ユーザーディレクトリ

### 拡張機能 (AUR)
- **gnome-shell-extensions** - シェル拡張サポート
- **extension-manager** - 拡張機能管理GUI
- **gnome-browser-connector** - ブラウザー拡張連携

## 特徴

### 利点
- **フル機能** - 包括的なデスクトップ環境
- **統合性** - アプリケーション間の優れた連携
- **アクセシビリティ** - 多様な支援技術サポート
- **Wayland対応** - モダンなディスプレイプロトコル

### 使用場面
- **一般的なデスクトップ利用** - Web、オフィス、マルチメディア
- **初心者ユーザー** - 直感的なユーザーインターフェース
- **生産性重視** - 統合されたワークフロー
- **マルチメディア** - 画像・動画・音楽管理

## 推奨設定

```yaml
gui:
  desktop: gnome
  display_manager: gdm    # GNOME標準
  fonts:
    enable_japanese: true
  inputmethod:
    enable: true
```

## 注意事項

1. **リソース使用量** - 他の環境より多めのメモリを使用
2. **カスタマイズ** - GNOMETweaksで詳細設定
3. **拡張機能** - extension-managerで機能拡張
4. **Waylandデフォルト** - X11アプリの互換性に注意
