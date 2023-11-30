# raspberry-ansible-home-nas
Ansible scripts to setup home NAS on Raspberry Pi
# Prerequisites

# On the controller machine
- Make sure Ansible is installed.
- Create SSH Pair.
- Start the ssh-agent service
    - `Set-Service ssh-agent -StartupType Automatic`
- ssh-add    
- Clone this repo

## On a fresh machine after image is deployed
- Enable SSH in Raspberry
- Copy the public key from above created SSH key pair


