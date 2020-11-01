#/usr/bin/env bash
ANSIBLE_CONFIG=./ansible.cfg ansible-playbook -i hosts_local.yml playbook_init.yml tags=init --ask-vault-pass