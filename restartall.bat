#!/bin/bash

docker-compose -f ./docker-compose.yml -f ./docker-compose-optional.yml restart || { echo >&2 "Error: docker-compose -f ./docker-compose.yml -f ./docker-compose-optional.yml restart failed."; exit 1; }
