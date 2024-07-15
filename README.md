# Ansible - Configure Raspberry Pi 4 as home NAS with Plex
Ansible scripts to setup home NAS on Raspberry Pi
- Require primary and secondary drives to backup every day 1 AM local time
- Require an email address credentials to send daily backup status

# Files to replace

- Replace your hosts in the hosts.ini file (localhost if running from same machine)
- Adjust the `files/nas-rsync.sh` file with your folders to sync. This tool is not synching entire drive but selected folders.
  - Make sure the above used folders are available in both the drives. 
- Replace the drive labels in `group_vars/all.yml`
  - Existing disks, drives and mount points can be seen using command `lsblk -o name,label,mountpoint,FSTYPE,size,FSUSE%,uuid`

# Running directly on RasPi - without controller node

## Prerequisite - On a fresh RasPi after image is deployed
- Install Ansible (Check tested versions below)

## Running 
- Clone this repo
- Do the replacements in required files
- Run the playbook rpi-playbook.yml file as follows
    - `ansible-playbook rpi-playbook.yml -i hosts.ini -e "email_password=<YOUR FROM EMAIL PASS>"`

# Running from controller node to setup remote RasPi
We need to setup both the controller and RasPi.
## Prerequisites - On a fresh RasPi after image is deployed
- Enable SSH in Raspberry

## Prerequisites - On the controller machine (Usually named as [jump box](https://en.wikipedia.org/wiki/Jump_server))
- Install Ansible (Check tested versions below)
- Create SSH Pair.
- Start the ssh-agent service
    - `Set-Service ssh-agent -StartupType Automatic`
- Add private key to ssh agent
    - `ssh-add `
- Copy the public key from above created SSH key pair to remote RasPi
    - `ssh-copy-id pi@raspberry` (make sure the user and hostname is correct)
- Install Ansible (Check tested versions below)
- Additional modules
  - List the modules `ansible-galaxy collection list`
- If the above command is not showing `ansible.posix` install using below command. This is needed for mounting
  - `ansible-galaxy collection install ansible.posix`

## Running (on the controller machine)
- Clone this repo
- Do the replacements in required files
- Run the playbook rpi-playbook.yml file as follows
    - `ansible-playbook rpi-playbook.yml -i hosts.ini -e "email_password=<YOUR FROM EMAIL PASS>"`

# Versions tested

Though mostly it works in other environments, please note that the scripts are tested only in below setup.

- Raspberry 4 Model B (4 GB)
- Raspberry Pi OS Lite
  - 64 bit
  - bookworm
- Ansible Core 2.16.0
<<<<<<< HEAD
- Python 3.10.12
=======
- Python 3.10.12

# References
- https://github.com/mkuthan/raspberry-ansible/tree/master
- https://github.com/glennklockwood/rpi-ansible/blob/master/host_vars/blackhall.yml
- https://github.com/notfoundsam/raspberry-plex-ansible
- https://thepi.io/how-to-set-up-a-raspberry-pi-plex-server/
- https://elvisciotti.medium.com/install-and-configure-a-raspberry-in-seconds-with-ansible-scrips-a0639ef38e1b
- https://github.com/HankB/Ansible
>>>>>>> c107caf67427b53b6d546a9e25bebcc419cf94fb
