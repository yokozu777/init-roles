#!/bin/bash
set -xe

PLAYBOOK_FILE="init-roles.yaml"

export GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no'

# SSH key: set SSH_KEY for config file, and ANSIBLE_PRIVATE_KEY_FILE for direct use (works without config)
export SSH_KEY="${SSH_KEY:-$HOME/mxhash_keys/id_rsa}"
export ANSIBLE_PRIVATE_KEY_FILE="${ANSIBLE_PRIVATE_KEY_FILE:-$SSH_KEY}"

ansible-playbook -i inventory-example.yml init-roles.yaml --tags "00_init,01_backup_etc,02_init_sshd,03_configure_users,04_configure_hostname,05_configure_sysctl_limits,\
06_configure_kernel,07_remove_unwanted_services,08_configure_security,09_configure_locales,10_manage_services,11_certificates,12_date_timezone,\
13_configure_repo,14_install_software,15_configure_bash,16_configure_network,17_update_reboot"

unset GIT_SSH_COMMAND
unset ANSIBLE_CONFIG