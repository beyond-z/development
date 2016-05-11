#!/bin/bash

docker-compose -f ./docker-compose.yml -f ./docker-compose-optional.yml stop || { echo >&2 "Error: docker-compose -f ./docker-compose.yml -f ./docker-compose-optional.yml stop failed."; exit 1; }

if [ "$(uname)" == "Darwin" ]; then
  # OS X platform
  echo "Stopping your local development environment for Mac"
  dinghy halt
fi


