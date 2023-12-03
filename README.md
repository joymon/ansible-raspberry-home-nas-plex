# raspberry-ansible-home-nas
Ansible scripts to setup home NAS on Raspberry Pi
# Prerequisites

## On a fresh machine after image is deployed
- Enable SSH in Raspberry
- Copy the public key from above created SSH key pair

## On the controller machine
- Make sure Ansible is installed.
- Create SSH Pair.
- Start the ssh-agent service
    - `Set-Service ssh-agent -StartupType Automatic`
- ssh-add    


# Running

## On a fresh machine without controller node
- Clone this repo
- Replace your hosts in the hosts.ini file
- Run the playbook rpi-playbook.yml file as follows
    - `ansible-playbook rpi-playbook.yml -i hosts.ini`
