# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this repo is

Ansible playbooks that configure a single Raspberry Pi 4 (Raspberry Pi OS Lite 64-bit, Bookworm) as a home NAS plus Pi-hole DNS server. Plex and Immich were removed, since they now run on a separate Talos home cluster. Don't reintroduce them here.

The user-facing documentation is `README.md`. Keep it in sync when behavior, variables, ports, or run commands change.

## Layout

- `rpi-playbook.yml` is the entry point. It runs apt update/upgrade, then `import_playbook`s every feature playbook in order:
  `nas` → `samba` → `nfs` → `docker` → `pihole` → `node-exporter`.
- `nas-playbook.yml` mounts the primary and backup drives by label and installs the daily 1 AM rsync cron job. It imports `nas-email-playbook.yml` (msmtp plus the status email).
- `samba-playbook.yml`, `nfs-playbook.yml`, `docker-playbook.yml`, `pihole-playbook.yml` and `node-exporter-playbook.yml` are one feature each.
- `files/` holds static files and Jinja2 templates (`*.j2`) pushed to the Pi.
- `group_vars/all.yml` holds all variables, namespaced by feature (`email`, `nas`, `pihole`, `docker`, `common`).
- `hosts.ini` is the inventory. Every play targets the `pis` group.
- `docs/homelab.drawio` is the home lab architecture diagram.
- `test.sh` is a scratch script and is not part of any playbook.

## Conventions

- Each feature gets its own `<feature>-playbook.yml`, wired into `rpi-playbook.yml` with `import_playbook`. There are no roles. Follow this pattern rather than introducing roles unless asked.
- Play header used throughout: `hosts: pis`, `user: pi`, `become: yes`, `become_user: root`.
- New files start with `# code: language=ansible` (helps the VS Code Ansible extension).
- New code should use fully-qualified module names (`ansible.builtin.apt`, `ansible.posix.mount`). Older playbooks use short names; don't churn them unless touching those tasks anyway.
- Add new variables under the feature's key in `group_vars/all.yml` and document them in `README.md`.
- Mount paths `/mnt/primary-exthdd` and `/mnt/backup-exthdd` are hard-coded across the NAS, Samba, NFS and rsync files. Changing them means updating all of those.
- Prefer idempotent modules over `command`/`shell`. When a shell step is unavoidable, use `creates:`/`removes:` or `changed_when:`.
- Docker services (for example Pi-hole) are deployed as a templated `docker-compose.yml` under an install dir, then `docker compose up -d`.

## Config and secrets (important)

- `group_vars/all.yml` and `hosts.ini` are committed with **placeholder values** (`<...>`). The owner keeps real values (IPs, drive labels, email addresses) as **uncommitted local edits**. Never commit, stage, or overwrite those real values. When editing these files, change only the lines you need and keep the placeholders in what gets committed.
- Secrets are passed at runtime only, never stored in the repo:
  - `email_password` for msmtp (also prompted via `vars_prompt`)
  - `pihole_web_password` for the Pi-hole admin UI
- Don't add plaintext passwords, tokens or personal emails to any tracked file.

## Running and checking

Ansible doesn't run natively on Windows. The controller is WSL/Linux or the Pi itself. From this Windows checkout you usually can't run playbooks, so say so instead of claiming they were tested.

```bash
# Full run
ansible-playbook rpi-playbook.yml -i hosts.ini \
  -e "email_password=<PASS>" -e "pihole_web_password=<PASS>"

# Single feature
ansible-playbook pihole-playbook.yml -i hosts.ini -e "pihole_web_password=<PASS>"

# Static checks (when Ansible is available)
ansible-playbook rpi-playbook.yml -i hosts.ini --syntax-check
ansible-lint            # if installed
ansible-playbook <playbook> -i hosts.ini --check --diff   # dry run against the Pi
```

Required collection: `ansible.posix` (`ansible-galaxy collection install ansible.posix`).

Manual verification steps for each feature (NAS, Pi-hole, Docker, Node Exporter) are in the "How to test" section of `README.md`.

## Git

- Commit message style: `<area> : <summary>` (for example `pihole : added the variables`, `docs : added homelab arch`).
- `main` is the default branch. Feature work goes through PRs.
