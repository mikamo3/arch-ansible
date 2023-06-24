#!/usr/bin/env bash
set -ex
e=$(echo "dev
local
remote" |fzf)

inv=$(ls -1 ./inventories/|fzf)

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