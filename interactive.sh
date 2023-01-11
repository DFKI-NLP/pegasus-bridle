#!/bin/bash

SCRIPT_DIR=$(dirname $0)
# import and check required environment variables
. "$SCRIPT_DIR"/import_vars.sh "$SCRIPT_DIR"/.env "CONTAINER_IMAGE" "PARTITION" "RESOURCE_ALLOCATION" "CONTAINER_WORKDIR" "CONTAINER_MOUNTS"

srun -K -p $PARTITION $RESOURCE_ALLOCATION \
    --container-image="$CONTAINER_IMAGE" \
    --container-workdir="$CONTAINER_WORKDIR" \
    --container-mounts="$CONTAINER_MOUNTS","$SCRIPT_DIR":"$SCRIPT_DIR" \
    --time 03:00:00 --pty /bin/bash \
    $*
