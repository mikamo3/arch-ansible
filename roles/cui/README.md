# CUI Role

コマンドライン環境を強化するための包括的なロール。モダンなCLIツール、シェル強化、エディターを含む。

## 含まれる機能

### Enhanced CLI Tools
モダンで高機能なコマンドラインツールの代替品

**基本ツールの置き換え:**
- `bat` - `cat`の代替（シンタックスハイライト付き）
- `exa` - `ls`の代替（カラー表示、Git統合）
- `htop` - `top`の代替（対話型プロセスビューアー）
- `btop` - モダンな`htop`代替
- `procs` - `ps`の代替（構造化表示）
- `fd` - `find`の代替（高速、Git対応）
- `duf` - `df`の代替（ディスク使用量）
- `dust` - `du`の代替（ディレクトリサイズ）

**検索とナビゲーション:**
- `fzf` - ファジーファインダー
- `ripgrep` - 高速な`grep`代替
- `the_silver_searcher` - `ag`検索ツール
- `zoxide` - インテリジェントな`cd`代替
- `ghq` - Gitリポジトリマネージャー
- `broot` - インタラクティブなディレクトリナビゲーション

**エディター:**
- `neovim` - モダンなVim

**ターミナル強化:**
- `starship` - カスタマイズ可能なプロンプト
- `zellij` - ターミナルマルチプレクサー
- `neofetch` - システム情報表示
- `delta` - Gitの美しいdiff表示

**シェル強化:**
- `fish` - モダンなシェル
- `fisher` - Fishプラグインマネージャー
- `bash-completion` - Bash補完機能
- `kitty-terminfo` - ターミナル互換性

**アーカイブツール:**
- `lha` - LHAアーカイブサポート
- `unarchiver` - 汎用アーカイブ展開ツール
- `unrar` - RARアーカイブサポート

**ユーティリティ:**
- `usage` - コマンド使用例表示
- `handlr` - ファイルハンドラー管理
- `tokei` - コード行数カウンター
- `hyperfine` - コマンドベンチマーク
- `tealdeer` - 簡潔なヘルプ（tldr）
- `bandwhich` - ネットワーク使用量監視
- `bottom` - システムモニター
- `watchexec` - ファイル監視・自動実行

**開発ツール:**
- `yq` - YAMLプロセッサー
- `httpie` - HTTPクライアント
- `curlie` - 改良されたcurl

**システム監視:**
- `bottom` - 代替システムモニター

### Kawazu
日本語入力サポートツール（詳細は`kawazu.yml`参照）

## 使用方法

### ロール全体の実行
```bash
ansible-playbook playbook.yml --tags cui
```

### 個別実行（タグ使用）
```bash
# Enhanced tools のみ
ansible-playbook playbook.yml --tags enhanced-tools

# Kawazu のみ  
ansible-playbook playbook.yml --tags kawazu
```

## 設定例

基本的には設定不要で、すべてのツールがデフォルトでインストールされます。

```yaml
# インベントリで特別な設定は不要
vars:
  # cui ロールは他の設定に依存しません
```

## インストール後の推奨設定

### Shell設定
各シェル（fish, bash, zsh）で以下の設定を推奨：

```bash
# エイリアス例（bashrc, zshrc等に追加）
alias ls='exa --icons --git'
alias ll='exa -la --icons --git'  
alias cat='bat'
alias find='fd'
alias grep='rg'

# zoxide初期化（必要に応じて）
eval "$(zoxide init bash)"
```

### Starship設定
`~/.config/starship.toml`でプロンプトをカスタマイズ可能

### Neovim設定
`~/.config/nvim/init.lua`でエディターの設定をカスタマイズ

## 注意事項

- すべてのツールはAURからインストールされます
- 初回インストール時は時間がかかる場合があります
- システムの既存コマンドは上書きされません（エイリアス推奨）

## 依存関係

- `base` ロール（AUR helperが必要）
- パッケージ管理システム（pacman + AUR helper）
