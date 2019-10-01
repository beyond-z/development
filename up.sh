#!/bin/bash

while read git_info_line; do
  if [[ $git_info_line =~ ^# ]]; then 
    # Skip comments
    continue;
  fi
  git_info=($git_info_line)
  repo_name=${git_info[0]}
  ( cd ${repo_name} && docker-compose up -d ) 
done < repos.txt
