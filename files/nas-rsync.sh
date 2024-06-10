#!/bin/bash
mkdir "/var/log/j3dnas/$(date +%F)" -p
rsync /mnt/primary-exthdd/audio/ /mnt/backup-exthdd/audio/ -av --progress --delete --out-format="%t %f %''b" >> "/var/log/j3dnas/$(date +%F)/audio.log" 2>&1
rsync /mnt/primary-exthdd/library/ /mnt/backup-exthdd/library/ -av --progress --delete --out-format="%t %f %''b" >> "/var/log/j3dnas/$(date +%F)/library.log" 2>&1
rsync /mnt/primary-exthdd/materials/ /mnt/backup-exthdd/materials/ -av --progress --delete --out-format="%t %f %''b" >> "/var/log/j3dnas/$(date +%F)/materials.log" 2>&1
rsync /mnt/primary-exthdd/media/ /mnt/backup-exthdd/media/ -av --progress --delete --out-format="%t %f %''b" >> "/var/log/j3dnas/$(date +%F)/media.log" 2>&1
rsync /mnt/primary-exthdd/software/ /mnt/backup-exthdd/software/ -av --progress --delete --out-format="%t %f %''b" >> "/var/log/j3dnas/$(date +%F)/software.log" 2>&1
rsync /mnt/primary-exthdd/users/ /mnt/backup-exthdd/users/ -av --progress --delete --out-format="%t %f %''b" >> "/var/log/j3dnas/$(date +%F)/users.log" 2>&1
/usr/local/bin/nas-rsync-email.sh