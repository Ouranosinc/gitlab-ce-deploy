#!/bin/sh -x
# Backup/restore DATA_VOL_NAME to/from BACKUP_OUT_DIR/DATA_VOL_NAME.tgz

DATA_VOL_NAME="$1"; shift
BACKUP_OUT_DIR="$1"; shift
MODE="$1"  # empty or value of RESTORE_MODE
RESTORE_MODE="restore"

if [ x"$MODE" != x"$RESTORE_MODE" ]; then
    MODE_MSG="create"
    VOLUME_MOUNT_OPT="ro"
    TAR_OPT="c"
    TAR_OPT2="."
else
    MODE_MSG="restore from"
    VOLUME_MOUNT_OPT="rw"
    TAR_OPT="x"
    TAR_OPT2=""
fi

echo "Will $MODE_MSG $BACKUP_OUT_DIR/$DATA_VOL_NAME.tgz"

docker run --rm \
  --name backup_data_vol_$DATA_VOL_NAME \
  -u root \
  -v $BACKUP_OUT_DIR:/backups \
  -v $DATA_VOL_NAME:/data_vol_to_backup:$VOLUME_MOUNT_OPT \
  bash \
  tar ${TAR_OPT}zf /backups/$DATA_VOL_NAME.tgz -C /data_vol_to_backup $TAR_OPT2

# vi: tabstop=8 expandtab shiftwidth=4 softtabstop=4
