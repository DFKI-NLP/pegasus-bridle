#!/bin/bash

SCRIPT_DIR=$(dirname $0)

# backup arguments and clear them (the source command fails otherwise)
ARGS=( "$@" )
shift $#

# activate conda environment, if the variable is defined
if [ -n "$CONDA_ENV" ]; then
    echo "activate conda environment: $CONDA_ENV"
    source /opt/conda/bin/activate
    conda activate $CONDA_ENV
fi

# if the variable PIP_REQUIREMENTS_FILE is defined, install the requirements
if [ -n "$PIP_REQUIREMENTS_FILE" ]; then
    echo "install pip requirements from $PIP_REQUIREMENTS_FILE"
    pip install -r "$PIP_REQUIREMENTS_FILE"
fi

# check for gpu availability
python "$SCRIPT_DIR"/check_cuda.py

# import environment variables from .env file
ENV_FILE=$(pwd)/.env
if [ -f "$ENV_FILE" ]; then
    echo ".env file found in current directory. load environment variables from $ENV_FILE"
    bash "$SCRIPT_DIR"/import_vars.sh "$ENV_FILE"
fi

# Login to Weights & Biases, if the wandb python package is installed
# and the environment variable WANDB_API_KEY is set.
python "$SCRIPT_DIR"/wandb_init.py

ARGS_JOINED=${ARGS[*]}
echo "execute: $ARGS_JOINED"
eval $ARGS_JOINED
