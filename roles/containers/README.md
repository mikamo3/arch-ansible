# Containers Role

Arch Linux環境でのDocker設定と管理ツールの提供を行うロール。
Nextcloud、Jellyfin、開発環境など、よく使われるサービスのコンテナ化を想定。

## 対応技術

### Docker
- **Docker Engine** - メインのコンテナランタイム  
- **Docker Buildx** - マルチアーキテクチャビルド対応
- **Docker Compose** - 家庭用サービス管理（Nextcloud、media servers等）

### 管理ツール
- **LazyDocker** - 初心者にも優しいTUI管理画面
- **cTop** - コンテナリソース監視

## 家庭での用途例

### メディアサーバー
- **Jellyfin** - 動画ストリーミング
- **Navidrome** - 音楽ストリーミング
- **PhotoPrism** - 写真管理

### 自宅クラウド
- **Nextcloud** - ファイル同期・共有
- **Vaultwarden** - パスワード管理
- **Home Assistant** - ホームオートメーション

### 開発環境
- **PostgreSQL/MySQL** - データベース
- **Redis** - キャッシュ
- **Node.js/Python** - 開発用コンテナ

## 設定オプション

```yaml
containers:
  docker:
    enable: true        # Docker インストール
    compose: true      # docker-compose インストール
    
  management_tools:
    enable: true       # TUI管理ツール

docker:
  enable_service: true # Docker サービス自動起動
```

## 使用例

### 基本設定（推奨）
```yaml
# デフォルト設定で家庭用途に最適
containers:
  docker:
    enable: true
    compose: true
  management_tools:
    enable: true
```

### 軽量設定
```yaml
# 管理ツール不要の場合
containers:
  docker:
    enable: true
  management_tools:
    enable: false
```

## インストールされるパッケージ

### Docker関連
- **Core**: docker, docker-buildx
- **Compose**: docker-compose (AUR)

### 管理ツール (AUR)  
- **TUI**: lazydocker, ctop

## 実行方法

```bash
# 全体実行
ansible-playbook playbook.yml --tags containers

# Docker のみ
ansible-playbook playbook.yml --tags docker

# 管理ツールのみ
ansible-playbook playbook.yml --tags container-tools
```

## 利用での注意点

1. **再ログイン必要**
   - dockerグループ追加後は再ログインが必要

2. **リソース使用量**
   - Docker daemonは常駐するためメモリを使用
   - 古いPCでは`docker.enable_service: false`推奨

3. **セキュリティ**
   - dockerグループはroot権限相当
   - 家庭内ネットワークでの使用を前提

4. **簡単なスタート**
   - LazyDockerを使って GUI ライクに操作可能
   - docker-compose.ymlのテンプレートを活用
