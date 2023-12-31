# Ansible - Configure Raspberry Pi 4 as home NAS with Plex
Ansible scripts to setup home NAS on Raspberry Pi
- Require primary and secondary drives to backup every day 1 AM local time
- Require an email address credentials to send daily backup status

# Running directly on RasPi

## On a fresh machine without controller node
- Install Ansible (Check tested versions below)
- Clone this repo
- Replace your hosts in the hosts.ini file (localhost)
- Run the playbook rpi-playbook.yml file as follows
    - `ansible-playbook rpi-playbook.yml -i hosts.ini -e "email_password=<YOUR FROM EMAIL PASS>`

# Running from controller node to setup remote RasPi

## Prerequisites

### On a fresh RasPi after image is deployed
- Enable SSH in Raspberry

### On the controller machine (Usually named as [jump box](https://en.wikipedia.org/wiki/Jump_server))
- Install Ansible (Check tested versions below)
- Create SSH Pair.
- Start the ssh-agent service
    - `Set-Service ssh-agent -StartupType Automatic`
- Add private key to ssh agent
    - `ssh-add `
- Copy the public key from above created SSH key pair to remote RasPi
    - `ssh-copy-id pi@raspberry` (make sure the user and hostname is correct)
- Install Ansible (Check tested versions below)

## Running (on the controller machine)
- Clone this repo
- Replace your hosts in the hosts.ini file (localhost)
- Run the playbook rpi-playbook.yml file as follows
    - `ansible-playbook rpi-playbook.yml -i hosts.ini -e "email_password=<YOUR FROM EMAIL PASS>`

# Versions tested

Though mostly it works in other environments, please note that the scripts are tested only in below setup.

- Raspberry 4 Model B (4 GB)
- Raspberry Pi OS Lite
  - 64 bit
  - bookworm
- Ansible Core 2.16.0
- Python 3.10.12

# References
- https://github.com/mkuthan/raspberry-ansible/tree/master
- https://github.com/glennklockwood/rpi-ansible/blob/master/host_vars/blackhall.yml
- https://github.com/notfoundsam/raspberry-plex-ansible
- https://thepi.io/how-to-set-up-a-raspberry-pi-plex-server/
- https://elvisciotti.medium.com/install-and-configure-a-raspberry-in-seconds-with-ansible-scrips-a0639ef38e1b
- https://github.com/HankB/Ansible
