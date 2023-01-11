#!/bin/bash

# import and check environment variables

# use the first argument as the environment variables file name
ENV_FILE="$1"

# check if that file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Environment file '$ENV_FILE' does not exist. Please create a copy of $ENV_FILE.example and adapt it for your needs."
    exit 1
fi

# import all vars from the that file
set -o allexport && source "$ENV_FILE" && set +o allexport

# interpret remaining arguments as names for environment variables that are required to exist
shift 1
required_vars=( "$@" )
for var_name in "${required_vars[@]}"
do
  var_value=${!var_name}
  if [[ -z "$var_value" ]]; then
    echo "$var_name is required, but undefined. All required vars: ${required_vars[*]}"
    exit 1
  else
    echo "$var_name=${!var_name}"
  fi
done
