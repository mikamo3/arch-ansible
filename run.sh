#!/usr/bin/env bash
set -ex
e=$(echo "dev
local
prod" |fzf)

inv=$(ls -1p ./inventories/| grep -v /|fzf)

if [[ "$1" != "" ]]; then
  TAGS="--tags=$1"
  shift
fi
ANSIBLE_CONFIG=./ansible.cfg ansible-playbook \
-i ./inventories/${inv} \
./playbook/${inv} \
-l $e \
--vault-password-file=".pass" \
--extra-vars="@password.yml" --diff $TAGS $@
