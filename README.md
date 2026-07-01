# Ansible - Raspberry Pi 4 Home NAS with Plex

Ansible playbooks to configure a Raspberry Pi as a home NAS with Plex. Syncs selected folders from primary to secondary drive daily at 1 AM and emails the backup status.

## Configuration

Before running, update these files:

- **`hosts.ini`** — set your target host (`localhost` if running on the Pi itself)
- **`files/nas-rsync.sh`** — list the folders to sync (not a full-drive mirror; ensure folders exist on both drives)
- **`group_vars/all.yml`** — set drive labels (use `lsblk -o name,label,mountpoint,FSTYPE,size,FSUSE%,uuid` to find them); optionally override Immich paths:
  - `immich.upload_location` (default: `/media`)
  - `immich.db_location` (default: `/media/databases/immich-postgres`)

## Usage

### Option A: Run directly on the Pi

1. Install Ansible on the Pi
2. Clone this repo
3. Apply configuration changes above
4. Run:
   ```
   ansible-playbook rpi-playbook.yml -i hosts.ini -e "email_password=<YOUR_EMAIL_PASS>" -e "immich_db_password=<YOUR_IMMICH_DB_PASS>"
   ```

### Option B: Run from a controller machine (Linux or WSL)

> Ansible does not run natively on Windows. Use a Linux machine or [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) as the controller.

**On the Pi:** Enable SSH.

**On the controller (Linux / WSL):**
1. Install Ansible
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
4. Clone this repo, apply configuration changes, then run:
   ```bash
   ansible-playbook rpi-playbook.yml -i hosts.ini -e "email_password=<YOUR_EMAIL_PASS>" -e "immich_db_password=<YOUR_IMMICH_DB_PASS>"
   ```

## Tested With

- Raspberry Pi 4 Model B (4 GB)
- Raspberry Pi OS Lite 64-bit (Bookworm)
- Ansible Core 2.16.0
- Python 3.10.12

## References

- https://github.com/mkuthan/raspberry-ansible/tree/master
- https://github.com/glennklockwood/rpi-ansible/blob/master/host_vars/blackhall.yml
- https://github.com/notfoundsam/raspberry-plex-ansible
- https://thepi.io/how-to-set-up-a-raspberry-pi-plex-server/
- https://elvisciotti.medium.com/install-and-configure-a-raspberry-in-seconds-with-ansible-scrips-a0639ef38e1b
- https://github.com/HankB/Ansible
