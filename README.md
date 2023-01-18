# Training models at the DFKI Slurm GPU Cluster

To train models at the cluster, we first need to set up a respective python environment. Then, we can call a wrapper
script that will start a Slurm job with a selected Enroot image and execute the command we passed to it within the job.
In the following, this is described in detail.

## Why should I use this setup?

- One time setup of the execution environment.
- Persistent cache.
- If an environment variables file `.env` is found in the current working directory, all contained variables are
  exported automatically and are available inside the Slurm job.
  
## :boom: IMPORTANT :boom:
This approach requires some manual housekeeping. Since the cache is persisted (by default to `/netscratch/$USER/.cache_slurm`), that needs to be cleaned up from time to time. It is also recommended to remove Conda environments when they are not needed anymore.

## Setup the working environment

1. Install Miniconda
   1. Download the miniconda setup script using the following command: <br>
      `wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh`
   2. Make the setup script executable and install miniconda using: `bash ./miniconda.sh` <br>
      IMPORTANT: It is recommended to use `/netscratch/$USER/miniconda3` as install location. <br>
      Note: If you want to choose another install directory, just adapt the respective environment variable
      `HOST_CONDA_ENVS_DIR` in the `.env` file (see below).
2. Setup a conda environment
   1. Create a conda environment, e.g. using: `conda create -n {env} python=3.9` (replace `{env}` with a name of your
      choice)
   2. Either start a [screen session](https://help.ubuntu.com/community/Screen) or make sure you are in bash (type `bash` in terminal) to make the conda commands available.
   3. Activate the environment: `conda activate {env}`
   4. Install any required python packages. We recommend that you use the PyPI cache installed at the cluster as described [here](http://projects.dfki.uni-kl.de/km-publications/web/ML/core/hpc-doc/posts/pypi-cache/), e.g. using:
      ```
      pip install --no-cache --index-url http://pypi-cache/index --trusted-host pypi-cache <package>
      ```
3. Get this code and cd into it: <br>
   `git clone https://github.com/DFKI-NLP/pegasus-bridle.git && cd pegasus-bridle`
4. Prepare the Slurm setup environment variable file
   1. Copy the [example file](.env.example): `cp .env.example .env`
   2. Adapt `.env` and ensure that the respective paths exist at the host and create them if
      necessary (especially for `HOST_CACHEDIR`)
   3. Make sure the images you are using contains a conda installation.

## Executing the code

1. Activate the conda environment at the host: `conda activate {env}`.<br>
   Note: This is just required to pass the conda environment name to the wrapper script. You can also set a fixed
   name by directly overwriting the environment variable `CONDA_ENV` in the `.env` file (see above).
2. Run `wrapper.sh` from anywhere, e.g. your project directory, and give the python command in the parameters to execute it:
   ```
   bash path/to/pegasus-bridle/wrapper.sh command with arguments
   ```
   Example Usage:
   ```
   bash /home/$USER/projects/pegasus-bridle/wrapper.sh python src/train.py +trainer.fast_dev_run=true
   ```

Notes:

- If an environment variables file `.env` is found in the **current working directory** (this is **not** the `.env` file you have created for the Slurm setup), all contained variables are exported automatically and are available inside the Slurm job.
- For more details about slurm cluster, please follow
  [this link](http://projects.dfki.uni-kl.de/km-publications/web/ML/core/hpc-doc/).

## For interactive mode

1. Run `bash path/to/interactive.sh` from your project directory
2. \[OPTIONAL\] Activate the conda environment inside the slurm job:
   1. Execute `source /opt/conda/bin/activate`
   2. Activate conda environment: `conda activate {env}`

Note: This uses the same environment variables as the wrapper.sh. You may modify them before starting an interactive
session, especially variables related to resource allocation.
