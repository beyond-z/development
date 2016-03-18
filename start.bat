#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
  # OS X platform
  echo "Starting you local development environment for Mac"
  dinghy up
fi

docker-compose up -d || { echo >&2 "Error: docker-compose up failed."; exit 1; }
