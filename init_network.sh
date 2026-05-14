#!/usr/bin/env bash
# Run after init.sh (in chroot, as root) to deploy NetworkManager profiles.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK="$REPO_ROOT/playbook/network_init.yml"

args=(ansible-playbook "$PLAYBOOK" --limit "$(hostname)" -c local)

if [[ ! -f "$REPO_ROOT/.vault_pass" ]]; then
  args+=(--ask-vault-pass)
fi

echo "$ ${args[*]}"
"${args[@]}"
