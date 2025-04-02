#!/bin/bash

# set -x

gitlab_config_backup_dir="/etc/gitlab/config_backup"
gitlab_data_backup_dir="/data/gitlab/backups"
oss_dir="/data/ossfs"

function gitlab_config_backup {
    gitlab-ctl backup-etc
}

function gitlab_data_backup {
    gitlab-backup create SKIP=uploads,builds,artifacts,registry,packages
}

function archive_backup {
    echo "gitlab_config start"
    cd $gitlab_config_backup_dir || exit
    sleep 2
    cp $(ls -t | head -n1) $oss_dir/gitlab_config.tar
    echo "gitlab_data start"
    cd $gitlab_data_backup_dir || exit
    sleep 2
    cp $(ls -t | head -n1) $oss_dir/dump_gitlab_backup.tar
}

function del_old {
    find $gitlab_config_backup_dir -mtime +7 -print0 |xargs -0 rm -vf
    find $gitlab_data_backup_dir -mtime +7 -print0 |xargs -0 rm -vf
}

function main {
    gitlab_config_backup
    gitlab_data_backup
    archive_backup
    del_old
}

main
