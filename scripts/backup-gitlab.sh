#!/bin/sh -x
# Backup to or restore from
# * /tmp/gitlab_data_persistence.tgz
# * /tmp/gitlab_logs_persistence.tgz
# * /tmp/gitlab_config_persistence.tgz
# with default values.
#
# Restore usage: BACKUP_OUT_DIR=/some/dir backup-gitlab.sh restore

cd `dirname "$0"`/..

if [ -z "$BACKUP_OUT_DIR" ]; then
    BACKUP_OUT_DIR=/tmp
fi

if [ -z "$DOCKER_USER_PERSISTENCE_VOLUMES" ]; then
    # dupe with docker-compose-wrapper.sh
    DOCKER_USER_PERSISTENCE_VOLUMES="gitlab_data_persistence gitlab_config_persistence gitlab_logs_persistence"
fi

for vol in $DOCKER_USER_PERSISTENCE_VOLUMES; do
    scripts/backup-datavolume.sh "$vol" "$BACKUP_OUT_DIR" "$@"
done

for vol in $DOCKER_USER_PERSISTENCE_VOLUMES; do
    ls -lh $BACKUP_OUT_DIR/$vol.tgz
done

# vi: tabstop=8 expandtab shiftwidth=4 softtabstop=4
