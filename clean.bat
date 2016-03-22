#!/bin/bash

# Remove all exited containers
docker rm $(docker ps -q -f status=exited)
