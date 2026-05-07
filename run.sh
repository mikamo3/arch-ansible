#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK="$REPO_ROOT/playbook/configure.yml"
INVENTORY="$REPO_ROOT/inventories/hosts.yml"

hosts=$(grep -E '^    [a-z]+:$' "$INVENTORY" | tr -d ' :')
tags=$(grep -oE 'tags: \[[a-z_]+\]' "$PLAYBOOK" | sed 's/tags: \[//;s/\]//')

target=$(echo "$hosts" | fzf \
  --prompt="Target > " \
  --height=~10 --border=rounded --info=hidden) \
  || { echo "Cancelled."; exit 0; }

connection=$(printf "remote\nlocal" | fzf \
  --prompt="Connection > " \
  --height=~6 --border=rounded --info=hidden) \
  || { echo "Cancelled."; exit 0; }

selected_tags=$(echo "$tags" | fzf \
  --prompt="Tags > " \
  --multi --height=~15 --border=rounded --info=hidden \
  --header="Tab: multi-select  Enter with no selection: all roles") \
  || true

dry_run=$(printf "run\ndry-run (--check)" | fzf \
  --prompt="Mode > " \
  --height=~6 --border=rounded --info=hidden) \
  || { echo "Cancelled."; exit 0; }

args=("ansible-playbook" "$PLAYBOOK" "--limit" "$target")
[[ "$connection" == "local" ]] && args+=("-c" "local")
if [[ -n "$selected_tags" ]]; then
  args+=("--tags" "$(echo "$selected_tags" | paste -sd,)")
fi
[[ "$dry_run" == dry-run* ]] && args+=("--check")

echo ""
echo "$ ${args[*]}"
echo ""
"${args[@]}"
