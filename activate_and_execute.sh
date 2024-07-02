#!/bin/bash

SCRIPT_DIR=$(dirname $0)

# backup arguments and clear them (the source command fails otherwise)
ARGS=( "$@" )
shift $#

if ! command -v conda > /dev/null 2>&1; then
    echo "Installing conda..."
    #wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O ~/miniconda.sh
    #bash ~/miniconda.sh -b -p $HOME/miniconda
    # Following https://docs.conda.io/projects/conda/en/latest/user-guide/install/rpm-debian.html
    # Install our public GPG key to trusted store
    curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg
    install -o root -g root -m 644 conda.gpg /usr/share/keyrings/conda-archive-keyring.gpg
    # Check whether fingerprint is correct (will output an error message otherwise)
    gpg --keyring /usr/share/keyrings/conda-archive-keyring.gpg --no-default-keyring --fingerprint 34161F5BF5EB1D4BFBBB8F0A8AEB4F8B29D82806
    # Add our Debian repo
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/conda-archive-keyring.gpg] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" > /etc/apt/sources.list.d/conda.list
    apt update
    apt install conda
    source /opt/conda/etc/profile.d/conda.sh
    conda -V
    echo "channels:" > /opt/conda/.condarc
    echo "  - conda-forge" >> /opt/conda/.condarc
    echo "channel_priority: strict" >> /opt/conda/.condarc
fi


# activate conda environment, if the variable is defined
if [ -n "$CONDA_ENV" ]; then
    echo "activate conda environment: $CONDA_ENV"
    source /opt/conda/bin/activate
    conda activate $CONDA_ENV
fi

PYTHON_VERSION=$(python --version)
echo "PYTHON VERSION: $PYTHON_VERSION"

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
    source "$SCRIPT_DIR"/import_vars.sh "$ENV_FILE"
fi

# Login to Weights & Biases, if the wandb python package is installed
# and the environment variable WANDB_API_KEY is set.
python "$SCRIPT_DIR"/wandb_init.py

ARGS_JOINED=${ARGS[*]}
echo "execute: $ARGS_JOINED"
eval $ARGS_JOINED
