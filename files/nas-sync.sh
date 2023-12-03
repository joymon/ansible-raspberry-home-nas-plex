#!/bin/bash
rsync /mnt/primary-exthdd/audio/ /mnt/backup-exthdd/audio/ -av --progress --delete --out-format="%t %f %''b" >> "/var/log/j3dnas/$(date +%F)/Media.log" 2>&1
#rsync /media/primary-exthdd/media/ /mnt/backup-exthdd/media/ -av --progress --delete --out-format="%t %f %''b" >> "/var/log/j3dnas/$(date +%F)/Media.log" 2>&1