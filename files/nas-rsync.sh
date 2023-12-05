#!/bin/bash
mkdir "/var/log/j3dnas/$(date +%F)" -p
rsync /mnt/primary-exthdd/audio/ /mnt/backup-exthdd/audio/ -av --progress --delete --out-format="%t %f %''b" >> "/var/log/j3dnas/$(date +%F)/audio.log" 2>&1
rsync /mnt/primary-exthdd/media/ /mnt/backup-exthdd/media/ -av --progress --delete --out-format="%t %f %''b" >> "/var/log/j3dnas/$(date +%F)/media.log" 2>&1

/usr/local/bin/nas-rsync-email.sh