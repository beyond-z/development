#!/bin/bash

docker-compose stop || { echo >&2 "Error: docker-compose stop failed."; exit 1; }

if [ "$(uname)" == "Darwin" ]; then
  # OS X platform
  echo "Stopping your local development environment for Mac"
  dinghy halt
fi


