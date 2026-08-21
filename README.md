# Ansible - Raspberry Pi 4 Home NAS with Plex

Ansible playbooks to configure a Raspberry Pi as a home NAS with Plex. Syncs selected folders from primary to secondary drive daily at 1 AM and emails the backup status.

## Configuration

Before running, update these files:

- **`hosts.ini`** — set your target Raspi IP (`localhost` if running on the Pi itself)
- **`files/nas-rsync.sh`** — list the folders to sync (not a full-drive mirror; ensure folders exist on both drives)
- **`[group_vars/all.yml](./group_vars/all.yml)`**
   - nas - details of your nas drives. primary and secondary disk labels
      - to get drive labels `lsblk -o name,label,mountpoint,FSTYPE,size,FSUSE%,uuid` 
   - email - details of from email and to everyday NAS sync status should be send.
   - samba - details of samba use and share name. The user will be created. Password to set later.
 
optionally override Immich paths:
- `immich.upload_location` (default: `/media`)
- `immich.db_location` (default: `/media/databases/immich-postgres`)

Below are the values to replace in all.yml
- 

Some values its assuming such as the below. Code changes required to different value.
- immich database location, immich media location
- nas mount paths.


## Usage

### Option A: Run directly on the Pi

1. Install Ansible on the Pi
2. Clone this repo
3. Apply configuration changes above
4. Run:
   ```
   ansible-playbook rpi-playbook.yml -i hosts.ini -e "email_password=<YOUR_EMAIL_PASS>" -e "immich_db_password=<YOUR_IMMICH_DB_PASS>"
   ```

### ✅ Option B: Run from a controller machine (Linux or WSL)

> Ansible does not run natively on Windows. Use a Linux machine or [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) as the controller.

**On the Pi:** Enable SSH.

**On the controller (Linux / WSL):**
1. Install Ansible. 
2. Generate an SSH key pair, start the agent, and copy the public key to the Pi:
   ```bash
   ssh-keygen
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_rsa
   ssh-copy-id pi@raspberry
   ```
3. Install the `ansible.posix` collection if missing:
   ```bash
   ansible-galaxy collection install ansible.posix
   ```
4. Clone this repo, apply the configuration changes as mentioned above.
5. Run:
   ```bash
   ansible-playbook rpi-playbook.yml -i hosts.ini -e "email_password=<YOUR_FROM_EMAIL_PASS>" -e "immich_db_password=<YOUR_IMMICH_DB_PASS>"
   ```
## How to test

### NAS
- Connect to the share from controller machine
- Try to send test mail using the `msmtp` command.

### Plex
- Browse below url from the controller machine
 - https://<Raspberry IP/ machine name>>:32400/

### Docker

- Run the `docker --version` command after remote into the Raspi

## Tested With

- Raspberry Pi 4 Model B (4 GB)
- Raspberry Pi OS Lite 64-bit (Bookworm)
- Ansible Core 2.21.3
- Python 3.14.4

## References

- https://github.com/mkuthan/raspberry-ansible/tree/master
- https://github.com/glennklockwood/rpi-ansible/blob/master/host_vars/blackhall.yml
- https://github.com/notfoundsam/raspberry-plex-ansible
- https://thepi.io/how-to-set-up-a-raspberry-pi-plex-server/
- https://elvisciotti.medium.com/install-and-configure-a-raspberry-in-seconds-with-ansible-scrips-a0639ef38e1b
- https://github.com/HankB/Ansible
