# Ansible - Raspberry Pi 4 Home NAS with Pi-hole

Ansible playbooks that turn a Raspberry Pi 4 with two USB hard drives into a home server:

- **NAS** – mounts a *primary* and a *backup* drive, shares them over **Samba** (Windows/macOS) and **NFS** (Linux).
- **Nightly backup** – selected folders are `rsync`-ed from the primary drive to the backup drive every day at 1 AM, and a status email is sent.
- **Pi-hole** – network-wide DNS ad blocker, running in **Docker**.
- **Node Exporter** – exposes Prometheus metrics (CPU, disk, network…) on port `9100`.

> Despite the repository name, Plex is **not** installed by these playbooks.

## Contents

- [What gets installed](#what-gets-installed)
- [Repository layout](#repository-layout)
- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
- [Usage](#usage)
- [Post-install steps](#post-install-steps)
- [How to test](#how-to-test)
- [Troubleshooting](#troubleshooting)
- [Tested with](#tested-with)

## What gets installed

`rpi-playbook.yml` is the entry point. It upgrades all apt packages and then imports the other playbooks in this order:

| Playbook | What it does on the Pi |
|---|---|
| `rpi-playbook.yml` | `apt update && apt upgrade`, then imports the playbooks below |
| `nas-playbook.yml` | Installs `ntfs-3g`; mounts the drives by label at `/mnt/primary-exthdd` and `/mnt/backup-exthdd` (added to `/etc/fstab`); copies `files/nas-rsync.sh` to `/usr/local/bin/` and schedules it as a root cron job at 01:00 |
| `nas-email-playbook.yml` | *(imported by `nas-playbook.yml`)* Installs `msmtp`, writes `/etc/msmtprc` with the SMTP settings, installs `/usr/local/bin/nas-rsync-email.sh` |
| `samba-playbook.yml` | Installs Samba, creates the share user, adds two shares to `/etc/samba/smb.conf`: `<nas.samba.share.name>` (read/write, primary drive) and `backup` (read-only, backup drive) |
| `nfs-playbook.yml` | Installs `nfs-kernel-server` and exports `/mnt/primary-exthdd` (read/write) to `nas.nfs.allowed_hosts` |
| `docker-playbook.yml` | Installs Docker using the official `get.docker.com` script (skipped if Docker already exists) |
| `pihole-playbook.yml` | Creates `/opt/pihole`, templates a `docker-compose.yml` and starts the Pi-hole container |
| `node-exporter-playbook.yml` | Installs and enables `prometheus-node-exporter` |

Each playbook can also be run on its own (see [Usage](#usage)).

### Nightly backup flow

```text
cron 01:00 ──► /usr/local/bin/nas-rsync.sh
                 ├─ rsync <folder> primary ──► backup   (one rsync per folder, with --delete)
                 │    logs: /var/log/j3dnas/<YYYY-MM-DD>/<folder>.log
                 └─► /usr/local/bin/nas-rsync-email.sh
                       └─ collects today's changes/deletions into status.txt and mails it via msmtp
```

> ⚠️ `rsync --delete` is used, so files removed from the primary drive are also removed from the backup drive on the next run.

## Repository layout

```text
.
├── rpi-playbook.yml            # Main entry point (runs everything)
├── nas-playbook.yml            # Drive mounts + nightly rsync cron
├── nas-email-playbook.yml      # msmtp + status email script
├── samba-playbook.yml
├── nfs-playbook.yml
├── docker-playbook.yml
├── pihole-playbook.yml
├── node-exporter-playbook.yml
├── hosts.ini                   # Inventory – the Pi's IP address
├── group_vars/all.yml          # All configurable variables
├── files/
│   ├── nas-rsync.sh            # Folders to back up (edit this)
│   ├── nas-rsync-email.sh.j2   # Status email script template
│   ├── msmtprc.j2              # SMTP client config template
│   └── pihole-compose.yml.j2   # Pi-hole docker-compose template
├── docs/homelab.drawio         # Home lab diagram (open with draw.io / diagrams.net)
└── test.sh                     # Scratch script, not used by the playbooks
```

## Prerequisites

- Raspberry Pi 4 running Raspberry Pi OS (64-bit, Bookworm) with a user named **`pi`** that has `sudo` rights. The playbooks connect as `pi` (`user: pi`); change that line in each playbook if your user differs.
- Two USB drives (ext4 or NTFS), each with a **filesystem label**. Find labels with:
  ```bash
  lsblk -o name,label,mountpoint,FSTYPE,size,FSUSE%,uuid
  ```
  To set a label: `sudo e2label /dev/sdX1 <label>` (ext4) or `sudo ntfslabel /dev/sdX1 <label>` (NTFS).
- An SMTP account for the status email. For Gmail, enable 2-step verification and create an [App Password](https://myaccount.google.com/apppasswords) – your normal Gmail password will not work.
- Ansible (Linux/WSL controller or on the Pi itself) and the `ansible.posix` collection.

## Configuration

Edit these files before running. **Do not commit real IPs, email addresses or passwords back to a public repository.**

### 1. `hosts.ini` – inventory

```ini
[pis]
192.168.1.50
```

Use the Pi's IP address. If you run Ansible **on the Pi itself**, use:

```ini
[pis]
localhost ansible_connection=local
```

### 2. `group_vars/all.yml` – variables

| Variable | Purpose | Example |
|---|---|---|
| `email.from.address` | SMTP login / sender address | `mynas@gmail.com` |
| `email.from.fullname` | Sender name in the email | `Home NAS` |
| `email.from.subject_prefix` | Subject prefix; the date is appended | `NAS Sync Status` |
| `email.smtp.host` / `port` | SMTP server (STARTTLS) | `smtp.gmail.com` / `587` |
| `email.to` | Single recipient of the daily status | `me@example.com` |
| `nas.primary_drive.label` | Label of the main data drive | `nasprimary` |
| `nas.primary_drive.fstype` | `ext4` or `ntfs` | `ntfs` |
| `nas.backup_drive.label` | Label of the backup drive | `nasbackup` |
| `nas.backup_drive.fstype` | `ext4` or `ntfs` | `ext4` |
| `nas.samba.user` | Linux + Samba user created for the shares | `shareuser` |
| `nas.samba.share.name` | Name of the read/write Samba share | `nas` |
| `nas.nfs.allowed_hosts` | Client IP / CIDR allowed to mount via NFS | `192.168.1.0/24` |
| `nas.nfs.share.name` | Only used as the marker in `/etc/exports` | `nas` |
| `pihole.version` | Pi-hole Docker image tag | `2026.09.0` |
| `pihole.install_dir` | Where the compose file and Pi-hole data live | `/opt/pihole` |
| `pihole.timezone` | Container timezone | `Etc/UTC` |
| `pihole.web_port` | Host port for the Pi-hole web UI | `8080` |

> `common.run_apt_upgrade` and `docker.version` exist in `all.yml` but are **not currently used** – `rpi-playbook.yml` always runs `apt upgrade`, and Docker installs the latest version from `get.docker.com`.

### 3. `files/nas-rsync.sh` – folders to back up

The backup is **not** a full-drive mirror. Each line rsyncs one top-level folder (`audio`, `library`, `materials`, `media`, `software`, `users` by default). Add, remove or rename lines to match the folders on your primary drive, and make sure each folder also exists on the backup drive.

### Secrets (passed at run time, never stored in the repo)

| Extra var | Used for | If omitted |
|---|---|---|
| `email_password` | SMTP password written to `/etc/msmtprc` | Ansible prompts for it |
| `pihole_web_password` | Pi-hole web admin password | **Run fails** at the Pi-hole step |

### Hard-coded values

These are fixed in the code; change the playbooks/scripts if you need different values:

- Mount points: `/mnt/primary-exthdd` and `/mnt/backup-exthdd`
- Backup schedule: 01:00 daily (`nas-playbook.yml`)
- Log directory: `/var/log/j3dnas/<date>/`
- SSH/remote user: `pi`
- Node Exporter port: `9100`; Pi-hole DNS port: `53`

## Usage

### Option A: Run directly on the Pi

1. Install Ansible and Git on the Pi:
   ```bash
   sudo apt update && sudo apt install -y ansible git
   ansible-galaxy collection install ansible.posix
   ```
2. Clone this repo and `cd` into it.
3. Apply the [configuration](#configuration) changes (use `localhost ansible_connection=local` in `hosts.ini`).
4. Run:
   ```bash
   ansible-playbook rpi-playbook.yml -i hosts.ini \
     -e "email_password=<YOUR_EMAIL_PASS>" \
     -e "pihole_web_password=<YOUR_PIHOLE_WEB_PASS>"
   ```

### ✅ Option B: Run from a controller machine (Linux or WSL) – recommended

> Ansible does not run natively on Windows. Use a Linux machine or [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) as the controller.

**On the Pi:** enable SSH (`sudo raspi-config` → *Interface Options* → *SSH*, or tick it in Raspberry Pi Imager).

**On the controller (Linux / WSL):**

1. Install Ansible and the required collection:
   ```bash
   sudo apt update && sudo apt install -y ansible
   ansible-galaxy collection install ansible.posix
   ```
2. Create an SSH key, load it into the agent and copy it to the Pi:
   ```bash
   ssh-keygen -t ed25519            # accept the default path
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ssh-copy-id pi@<Raspberry IP>
   ```
3. Clone this repo and apply the [configuration](#configuration) changes.
4. Check connectivity:
   ```bash
   ansible pis -i hosts.ini -u pi -m ping
   ```
5. Run:
   ```bash
   ansible-playbook rpi-playbook.yml -i hosts.ini \
     -e "email_password=<YOUR_FROM_EMAIL_PASS>" \
     -e "pihole_web_password=<YOUR_PIHOLE_WEB_PASS>"
   ```

> Tip: prefix the command with a space (or use `read -s`) to keep passwords out of your shell history.

### Running a single component

Every playbook targets the same `pis` group, so you can re-run just one part:

```bash
ansible-playbook samba-playbook.yml -i hosts.ini
ansible-playbook nas-playbook.yml   -i hosts.ini -e "email_password=<PASS>"
ansible-playbook pihole-playbook.yml -i hosts.ini -e "pihole_web_password=<PASS>"
```

Note: `pihole-playbook.yml` requires Docker, so run `docker-playbook.yml` first on a fresh Pi.

### Jumpbox controller (Windows + WSL) – reusing an existing key

If you already have a private key (e.g. on the Windows side), make it available permanently in WSL:

```bash
cp /mnt/c/path/to/id_rsa ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

## Post-install steps

1. **Set the Samba password** – the playbook creates the user but not its Samba password:
   ```bash
   sudo smbpasswd -a <nas.samba.user>
   ```
2. **Point clients at Pi-hole** – set `<Raspberry IP>` as the DNS server on your router (DHCP settings) or on individual devices.
3. **Give the Pi a fixed IP** – reserve its address in your router so the inventory, NFS mounts and DNS settings keep working.

## How to test

### NAS

- **Samba:** from Windows, open `\\<Raspberry IP>\<share name>` (or `\\<Raspberry IP>\backup` for the read-only backup) and sign in with the Samba user. From macOS: `smb://<Raspberry IP>/<share name>`.
- **NFS:** from an allowed Linux client:
  ```bash
  sudo mount -t nfs <Raspberry IP>:/mnt/primary-exthdd <local mount point>
  ```
- **Email:** on the Pi, send a test mail:
  ```bash
  echo -e "Subject: msmtp test\n\nHello from the NAS" | sudo msmtp -t <recipient>
  ```
- **Backup job:** run it manually and check the logs:
  ```bash
  sudo /usr/local/bin/nas-rsync.sh
  ls /var/log/j3dnas/$(date +%F)/
  ```

### Pi-hole

- Open `http://<Raspberry IP>:8080/admin/` and sign in with the password supplied to Ansible.
- Confirm DNS resolution and ad blocking from a client, e.g. `nslookup doubleclick.net <Raspberry IP>` should return `0.0.0.0`.

### Docker

- SSH into the Pi and run `docker --version` and `sudo docker ps` (the `pihole` container should be listed).

### Node Exporter

- Open `http://<Raspberry IP>:9100/metrics` from a monitoring host.
- Confirm that network metrics such as `node_network_receive_bytes_total` and `node_network_transmit_bytes_total` are present.

## Troubleshooting

| Symptom | Likely cause / fix |
|---|---|
| `couldn't resolve module/action 'ansible.posix.mount'` | Run `ansible-galaxy collection install ansible.posix` |
| Mount task fails | Wrong drive label or `fstype` in `group_vars/all.yml`; check with `lsblk -o name,label,FSTYPE` |
| `'pihole_web_password' is undefined` | Pass `-e "pihole_web_password=..."` |
| Pi-hole container won't start, port 53 in use | Another DNS service (e.g. `systemd-resolved`, `dnsmasq`) is listening on port 53 |
| No status email | Check `/var/log/msmtp.log`; for Gmail use an App Password |
| Rsync log shows "No such file or directory" | Folder listed in `files/nas-rsync.sh` doesn't exist on one of the drives |

## Tested with

- Raspberry Pi 4 Model B (4 GB)
- Raspberry Pi OS Lite 64-bit (Bookworm)
- Ansible Core 2.21.3
- Python 3.14.4

## References

- https://github.com/mkuthan/raspberry-ansible/tree/master
- https://github.com/glennklockwood/rpi-ansible/blob/master/host_vars/blackhall.yml
- https://elvisciotti.medium.com/install-and-configure-a-raspberry-in-seconds-with-ansible-scrips-a0639ef38e1b
- https://github.com/HankB/Ansible
