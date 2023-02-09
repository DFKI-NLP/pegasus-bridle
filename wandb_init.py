#!/usr/bin/python
# -*- coding: utf8 -*-
"""

@date: 07.02.23
@author: leonhard.hennig@dfki.de
"""

import os
from importlib.util import find_spec


def prepare_wandb():
    # if wandb is installed
    if find_spec("wandb"):
        import wandb
        wandb_api_key = os.getenv("WANDB_API_KEY", None)
        if wandb_api_key is not None:
            print('Logging into wandb')
            wandb.login(key=wandb_api_key)
