# Ansible - Raspberry Pi 4 Home NAS with Pi-hole

Ansible playbooks to configure a Raspberry Pi as a home NAS and Pi-hole DNS server. Selected folders are synced from the primary to the secondary drive daily at 1 AM and the backup status is emailed.

## Configuration

Before running, update these files:

- **`hosts.ini`** — set your target Raspi IP (`localhost` if running on the Pi itself)
- **`files/nas-rsync.sh`** — list the folders to sync (not a full-drive mirror; ensure folders exist on both drives)
- **`[group_vars/all.yml](./group_vars/all.yml)`**
   - nas - details of your nas drives. primary and secondary disk labels
      - to get drive labels `lsblk -o name,label,mountpoint,FSTYPE,size,FSUSE%,uuid` 
   - email - details of from email and to everyday NAS sync status should be send.
   - samba - details of samba use and share name. The user will be created. Password to set later.
   - nfs - allowed client network and share name. NFS clients mount `/mnt/primary-exthdd` directly.
 
Pi-hole defaults are also in `group_vars/all.yml`:
- `pihole.timezone` (default: `Etc/UTC`)
- `pihole.web_port` (default: `8080`)
- `pihole.install_dir` (default: `/opt/pihole`)

Set the Pi-hole web password when running the playbook with `pihole_web_password`. Do not commit the password to this repository.

Some values its assuming such as the below. Code changes required to different value.
- nas mount paths.


## Usage

### Option A: Run directly on the Pi

1. Install Ansible on the Pi
2. Clone this repo
3. Apply configuration changes above
4. Run:
   ```
   ansible-playbook rpi-playbook.yml -i hosts.ini -e "email_password=<YOUR_EMAIL_PASS>" -e "pihole_web_password=<YOUR_PIHOLE_WEB_PASS>"
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
   ansible-playbook rpi-playbook.yml -i hosts.ini -e "email_password=<YOUR_FROM_EMAIL_PASS>" -e "pihole_web_password=<YOUR_PIHOLE_WEB_PASS>"
   ```
## How to test

### NAS
- Connect to the share from controller machine
- Mount the NFS share with `mount -t nfs <Raspberry IP>:/mnt/primary-exthdd <local mount point>`
- Try to send test mail using the `msmtp` command.

### Pi-hole
- Open `http://<Raspberry IP>:8080/admin/` and sign in with the password supplied to Ansible.
- Configure your router or individual clients to use `<Raspberry IP>` as their DNS server.
- Confirm DNS resolution and ad blocking from a connected client.

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
- https://elvisciotti.medium.com/install-and-configure-a-raspberry-in-seconds-with-ansible-scrips-a0639ef38e1b
- https://github.com/HankB/Ansible
