#!/bin/bash
# Temporarily stop the Chef Infra Server, run the backup, restart the
# server, upload the latest backup file to S3, then delete the backup
# file.
# 
# The backup file will be prefixed with the Chef version when uploaded
# to S3.
set -e

CHEF_VERSION=$(chef-server-ctl version)
sudo chef-server-ctl backup --yes

BACKUP_FILE=$(ls -Art /var/opt/chef-backup | tail -n 1)

aws s3 cp "/var/opt/chef-backup/$BACKUP_FILE" "s3://gswlab-chef-backups/chef-infra-server/v$CHEF_VERSION-$BACKUP_FILE" --storage-class STANDARD_IA

sudo rm "/var/opt/chef-backup/$BACKUP_FILE"