#!/bin/bash

./_setup_clone_repos.sh
./_setup_etc_hosts.sh && \
./_setup_aws.sh && \
./_setup_heroku.sh && \
./rebuild_and_restart.sh
