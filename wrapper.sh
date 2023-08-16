#!/bin/bash
# Script to execute code on the slurm cluster in the current conda environment.
# Example Usage: bash scripts/gpu_cluster/wrapper.sh python src/train.py +trainer.fast_dev_run=true

SCRIPT_DIR=$(dirname $0)

# check if an environment file is provided in the current directory
ENV_FILE="$(pwd)/.pegasus-bridle.env"
if [ -f "$ENV_FILE" ]; then
    echo "INFO: .pegasus-bridle.env file found in current directory. load environment variables from $ENV_FILE"
else
    ENV_FILE="$SCRIPT_DIR"/.env
    echo "WARNING: no .pegasus-bridle.env file found in current directory. use environment variables from $ENV_FILE"
fi

# import and check required environment variables
. "$SCRIPT_DIR"/import_vars.sh "$ENV_FILE" "CONTAINER_IMAGE" "PARTITION" "RESOURCE_ALLOCATION" "CONTAINER_WORKDIR" "CONTAINER_MOUNTS" "EXPORT"

srun -K -p $PARTITION $RESOURCE_ALLOCATION \
    --container-image="$CONTAINER_IMAGE" \
    --container-workdir="$CONTAINER_WORKDIR" \
    --container-mounts="$CONTAINER_MOUNTS","$SCRIPT_DIR":"$SCRIPT_DIR" \
    --export="$EXPORT" \
    bash "$SCRIPT_DIR"/activate_and_execute.sh $*
