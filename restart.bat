#!/bin/bash

docker-compose restart || { echo >&2 "Error: docker-compose restart failed."; exit 1; }
