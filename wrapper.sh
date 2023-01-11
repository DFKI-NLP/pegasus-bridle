#!/bin/bash
# Script to execute code on the slurm cluster in the current conda environment.
# Example Usage: bash scripts/gpu_cluster/wrapper.sh python src/train.py +trainer.fast_dev_run=true

SCRIPT_DIR=$(dirname $0)
# import and check required environment variables
. "$SCRIPT_DIR"/import_vars.sh "$SCRIPT_DIR"/.env "CONTAINER_IMAGE" "PARTITION" "RESOURCE_ALLOCATION" "CONTAINER_WORKDIR" "CONTAINER_MOUNTS" "CONDA_ENV"

srun -K -p $PARTITION $RESOURCE_ALLOCATION \
    --container-image="$CONTAINER_IMAGE" \
    --container-workdir="$CONTAINER_WORKDIR" \
    --container-mounts="$CONTAINER_MOUNTS","$SCRIPT_DIR":"$SCRIPT_DIR" \
    --export="NCCL_SOCKET_IFNAME=bond,NCCL_IB_HCA=mlx5" \
    bash "$SCRIPT_DIR"/activate_and_execute.sh "$CONDA_ENV" $*
