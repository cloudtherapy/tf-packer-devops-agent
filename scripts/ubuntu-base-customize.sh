#!/bin/bash -e

main() {
  
  log "Environment"
  if [[ -f /etc/os-release ]]; then cat /etc/os-release; fi
  log "apt-get -y update" 
  sudo apt-get -y update
  log "apt-get install ansible" 
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ansible
  log "apt-get -y upgrade" 
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
  log "apt-get autoremove" 
  sudo apt-get autoremove -y
  log "apt-get clean" 
  sudo apt-get clean
  log "ansible version"
  ansible --version
  log "run ansible playbook"
  ansible-playbook /tmp/ansible-ubuntu-image.yml
  log "remove ansible playbook"
  rm /tmp/ansible-ubuntu-image.yml
}

log() {
  echo
  echo "[[ ${1} ]]"
  echo
}

main