#!/bin/bash

echo "This script needs to be updated to setup https://github.com/bebraven/canvas-lms instead of https://github.com/beyond-z/canvas-lms"
echo "Also, ideally it would directly clone the repo's instead of making people fork them first. We want to switch our dev flow away from the open source fork flow to just be branch based off the team repo."
exit 1;

# Setup subdirectories for each project using forked versions of each.  Note: we initially
# tried to use git submodules, but it was too hard to actively develop using those with a fork/pull workflow
echo "Cloning all repositories.  IMPORTANT: this assumes that you've forked each repository already"
current_repo=`git config --get remote.origin.url`
if [[ $current_repo == "https://github.com/beyond-z/development"* ]]; then
  echo "You should not run this using the https://github.com/beyond-z/development repository.  Instead, use a fork!"
  exit 1;
fi
if [[ $current_repo != *".git" ]]; then
  echo "This script assumes the remote origin url ends with '.git'.  Please clone this using 'git clone https://github.com/[your_username]/development.git development'"
  exit 1;
fi

origin_url=${current_repo%development.git}
while read git_info_line; do
  if [[ $git_info_line =~ ^# ]]; then 
    # Skip comments
    continue;
  fi
  git_info=($git_info_line)
  repo_name=${git_info[0]}
  branch_name=${git_info[1]}
  if [ -d $repo_name/.git ]; then
    update_cmd_to_run1="git checkout ${branch_name}"
    update_cmd_to_run2="git pull upstream ${branch_name}"
    echo "Running: cd $repo_name && $update_cmd_to_run1 && $update_cmd_to_run2"
    (cd $repo_name && $update_cmd_to_run1 && $update_cmd_to_run2 || { echo >&2 "Error: failed to pull from upstream."; exit 1; })
    # TODO: automate this
    echo "### The $repo_name repo was already on your local machine. You may have to rebuild the docker image b/c new code was pulled from upstream by running:"
    echo "cd $repo_name && ./docker-compose/scripts/rebuild.sh"
  else
    clone_cmd_to_run="git clone ${origin_url}${repo_name} ${repo_name}"
    echo "Running: $clone_cmd_to_run"
    $clone_cmd_to_run || { echo >&2 "Error: Make sure you have forked ${repo_name}"; exit 1; }
    echo "Adding upstream: $upstream_cmd_to_run"
    if [[ $repo_name == 'platform' ]]; then 
      echo "Skipping for Platform. Not part of beyond-z"
      continue;
    else
      upstream_cmd_to_run="git remote add upstream https://github.com/beyond-z/${repo_name}"
      (cd $repo_name && $upstream_cmd_to_run || { echo >&2 "Error: failed to add upstream remote."; exit 1; })
    fi
  fi
done < repos.txt

# TODO: set these paths in the above loop so they are controlled by repos.txt
bash_src_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
join_src_path="$( cd $bash_src_path; cd beyondz-platform && pwd )"
canvas_src_path="$( cd $bash_src_path; cd canvas-lms && pwd )"
canvasjscss_src_path="$( cd $bash_src_path; cd canvas-lms-js-css && pwd )"
sso_src_path="$( cd $bash_src_path; cd rubycas-server && pwd )"
kits_src_path="$( cd $bash_src_path; cd kits && pwd )"
bebraven_src_path="$( cd $bash_src_path; cd braven_2 && pwd )"
nginx_dev_src_path="$( cd $bash_src_path; cd nginx-dev && pwd )"
platform_src_path="$( cd $bash_src_path; cd platform && pwd )"

if [ "$(uname)" == "Darwin" ]; then
  # OS X platform
  echo "Setting up Docker VM for Mac"

  docker -v &> /dev/null || { echo >&2 "Error: somethings wrong with docker. Go download Docker For Mac from dockerhub (you have to create an account) and make sure docker -v works"; exit 1; }

  if ! aws --version &> /dev/null; then
    # Install AWS CLI if it's not there
    echo "Error: Please install 'aws'. E.g."
    echo "  $ pip3 install awscli"
    echo ""
    echo "If you don't have pip3, download and install Python 3x which has it: https://www.python.org/ftp/python/3.7.4/python-3.7.4-macosx10.9.pkg"
    echo ""
    echo "You MUST run 'aws configure' after to setup permissions, putting in your IAM Access and Secret Tokens. Use us-west-1 for the region."
    exit 1;
  fi

  echo "Checking if the AWS ENV vars are setup"
  if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "The AWS ENV vars arent setup. TODO: add these to your .bash_profile"
    echo '  export AWS_ACCESS_KEY_ID=<yourkey>'
    echo '  export AWS_SECRET_ACCESS_KEY=<yoursecretkey>'
    exit 1
  else
    echo "You good!"
  fi

  # TODO: this only really works for the the first time install. If one of the container's gets built
  # and is out of date needing a rebuild, this script doesn't handle that. It probably should. Maybe change
  # everything to run the docker-compose/scripts/rebuild script?

  echo "Setting up Canvas JS/CSS development environment at: $canvasjscss_src_path"
  (cd $canvasjscss_src_path && docker-compose up -d || { echo >&2 "Error: docker-compose build failed."; exit 1; })

  echo "Setting up SSO, aka rubycas-server development environment at: $sso_src_path"
  (cd $sso_src_path && docker-compose up -d || { echo >&2 "Error: docker-compose build failed."; exit 1; })

  echo "Setting up Join development environment at: $join_src_path"

  echo "Setting up Platform development environment at: $platform_src_path"
  (cd $platform_src_path && docker-compose up -d || { echo >&2 "Error: docker-compose build failed."; exit 1; })

  # TODO: verify this is still necessary and either remove or uncomment.
  # This file changes locally in the dev env.  We need it in src ctrl for Travis 
  # to work but we want to ignore local changes.
  #(cd $join_src_path && git update-index --assume-unchanged config/database.yml)

  (cd $join_src_path && docker-compose up -d || { echo >&2 "Error: docker-compose build failed."; exit 1; })

  echo "Setting up Kits development environment at: $kits_src_path"
  (cd $kits_src_path && docker-compose up -d || { echo >&2 "Error: docker-compose build failed."; exit 1; })

  echo "Setting up BeBraven.org development environment at: $bebraven_src_path"
  (cd $bebraven_src_path && docker-compose up -d || { echo >&2 "Error: docker-compose build failed."; exit 1; })

  echo "Setting up Portal aka Canvas/LMS development environment at: $canvas_src_path"
  (cd $canvas_src_path && docker-compose up -d || { echo >&2 "Error: docker-compose build failed."; exit 1; })

  echo "Setting up nginx-dev service so we dont have to use port numbers in the dev environment at: $nginx_dev_src_path"
  (cd $nginx_dev_src_path && docker-compose up -d || { echo >&2 "Error: docker-compose build failed."; exit 1; })

  echo "Loading a dev DB into your Join dev env"
  (cd $join_src_path && docker-compose exec joinweb bundle exec rake db:create && ./docker-compose/scripts/dbrefresh.sh || { echo >&2 "Error: ./docker-compose/scripts/dbrefresh.sh failed."; exit 1; })

  echo "Loading a dev DB into your Portal dev env"
  (cd $canvas_src_path && docker-compose exec canvasweb bundle exec rake db:create && ./docker-compose/scripts/dbrefresh.sh || { echo >&2 "Error: ./docker-compose/scripts/dbrefresh.sh failed."; exit 1; })

  echo "Loading a dev DB into your Kits dev env"
  (cd $kits_src_path && ./docker-compose/scripts/dbrefresh.sh || { echo >&2 "Error: ./docker-compose/scripts/dbrefresh.sh failed."; exit 1; })

  echo "Loading the dev uploads and plugins into your Kits dev env"
  (cd $kits_src_path && ./docker-compose/scripts/contentrefresh.sh || { echo >&2 "Error: ./docker-compose/scripts/contentrefresh.sh failed."; exit 1; })

  echo "Loading a dev DB into your BeBraven.org dev env and downloading uploads and plugins"
  (cd $bebraven_src_path && ./docker-compose/scripts/dbrefresh.sh || { echo >&2 "Error: ./docker-compose/scripts/dbrefresh.sh failed."; exit 1; })

  echo "Loading the dev DB into your Platform dev env"
  # @TODO: Populate DBs with values from server when ready
  (cd $platform_src_path && docker-compose exec platformweb bundle exec rake db:create db:schema:load db:migrate db:seed)

  echo "Checking if /etc/hosts needs to be setup"
  ./setup_etc_hosts.sh

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  # GNU/Linux platform
  echo "ERROR: setup script not written for Linux.  Please write it!"
  exit 1;
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  # Windows NT platform
  echo "ERROR: setup script not written for Windows.  Please write it!"
  exit 1;
fi

echo "Setup complete!"
