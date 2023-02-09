#!/bin/bash

SCRIPT_DIR=$(dirname $0)

# use first argument as conda environment name
CONDA_ENV=$1
shift

# backup arguments and clear them (the source command fails otherwise)
ARGS=( "$@" )
shift $#

echo "activate conda environment: $CONDA_ENV"
source /opt/conda/bin/activate
conda activate $CONDA_ENV

# check for gpu availability
python "$SCRIPT_DIR"/check_cuda.py

# import environment variables from .env file
ENV_FILE=$(pwd)/.env
if [ -f "$ENV_FILE" ]; then
    echo ".env file found in current directory. load environment variables from $ENV_FILE"
    bash "$SCRIPT_DIR"/import_vars.sh "$ENV_FILE"
fi

# check wandb and login
python "$SCRIPT_DIR"/wandb_init.py

ARGS_JOINED=${ARGS[*]}
echo "execute: $ARGS_JOINED"
eval $ARGS_JOINED
