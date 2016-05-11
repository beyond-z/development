#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
  # OS X platform
  echo "Starting you local development environment for Mac"
  dinghy up
fi

docker-compose -f ./docker-compose.yml -f docker-compose-optional.yml up -d || { echo >&2 "Error: docker-compose -f ./docker-compose.yml -f docker-compose-optional.yml up failed."; exit 1; }
