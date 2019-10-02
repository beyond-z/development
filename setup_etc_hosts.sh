#!/bin/bash

hosts_to_add=''
while read git_info_line; do
  if [[ $git_info_line =~ ^# ]]; then
    # Skip comments
    continue;
  fi
  git_info=($git_info_line)
  repo_name=${git_info[0]}
  host_name=${git_info[2]}
  if ! grep -q "^[^#].*${host_name}" /etc/hosts; then
    new_host="127.0.0.1	$host_name"
    new_host+=$'\n'
    hosts_to_add+=$new_host
  fi
done < repos.txt

if [ ! -z "$hosts_to_add" ];
then
 if [ $EUID != 0 ]; then
    echo "Requesting elevated privileges to edit /etc/hosts."
    sudo "$0" "$@"
    exit $?
  else
    echo "Adding the following to /etc/hosts:"
    echo "$hosts_to_add"
    echo "$hosts_to_add" >> /etc/hosts
  fi
else
  echo "/etc/hosts is alread setup. Skipping!"
fi

