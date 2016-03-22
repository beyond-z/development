#!/bin/bash

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
while read repo_name; do
  if [ -d $repo_name/.git ]; then
    echo "Skipping clone of $repo_name because it already exists"
  else
    clone_cmd_to_run="git clone ${origin_url}${repo_name} ${repo_name}"
    echo "Running: $clone_cmd_to_run"
    $clone_cmd_to_run || { echo >&2 "FAILED. Make sure you have forked ${repo_name}"; exit 1; }
    upstream_cmd_to_run="git remote add upstream https://github.com/beyond-z/${repo_name}"
    echo "Adding upstream: $upstream_cmd_to_run"
    $upstream_cmd_to_run
  fi
done < repos.txt

bash_src_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
join_src_path="$( cd $bash_src_path; cd beyondz-platform && pwd )"
canvas_src_path="$( cd $bash_src_path; cd canvas-lms && pwd )"
sso_src_path="$( cd $bash_src_path; cd rubycas-server && pwd )"

vboxmanage --version &> /dev/null || { echo >&2 "VirtualBox not installed.  Please install it first"; exit 1; }
vboxmanage list extpacks &> /dev/null || { echo >&2 "VirtualBox Extension pack not installed.  Please install it first"; exit 1; }

if [ "$(uname)" == "Darwin" ]; then
  # OS X platform
  echo "Setting up Docker VM for Mac"

  if ! dinghy version &> /dev/null; then
    echo "Installing dinghy"
    git clone https://github.com/codekitchen/dinghy.git ../dinghy
    if [ $? -ne 0 ]
    then
     echo "Failed cloning dinghy source code"
     exit 1;
    fi
    cd ../dinghy
    brew update || { echo >&2 "Error: brew update failed!"; exit 1; }

    brew tap codekitchen/dinghy
    brew install dinghy
    # TODO: there is a bug in the stable dinghy that prevents the http proxy from working.  Using master to fix it.
    # See: https://github.com/codekitchen/dinghy/issues/135
    # Revert to stable version once it's fixed there.
    #brew install --HEAD dinghy
    if [ $? -ne 0 ]
    then
     echo "Failed installing dinghy to $(pwd)"
     exit 1;
    fi
    brew install docker docker-machine || { echo >&2 "Error: brew install docker docker-machine failed!"; exit 1; }

    dingyoutput="$(dinghy create --memory=4096 --cpus=4 --provider=virtualbox)"
    if [ $? -ne 0 ]
    then
     echo "Failed creating dinghy VM: dinghy create --memory=4096 --cpus=4 --provider=virtualbox"
     exit 1;
    fi

    # TODO!!! grab the ENV variables output by dinghy create and add them to .bashrc
    # e.g. 
    # export DOCKER_HOST=tcp://192.168.99.100:2376
    # export DOCKER_CERT_PATH=/Users/sadleb/.docker/machine/machines/dinghy
    # export DOCKER_TLS_VERIFY=1
    # export DOCKER_MACHINE_NAME=dinghy

    read response $'Please add the above ENV variables to your ~/.bashrc and hit Enter'
    source ~/.bashrc

    echo "Installed dinghy to $(pwd)"
  fi

  dinghy up || { echo >&2 "Error: dinghy up failed."; exit 1; }
  docker ps &> /dev/null || { echo >&2 "Error: somethings wrong with docker.  Make sure this command lists your containers: docker ps"; exit 1; }

  if ! docker-compose --version &> /dev/null; then
    echo "Installing docker-compose"
    brew install docker-compose --without-boot2docker || { echo >&2 "Error: brew install docker-compose --without-boot2docker failed!"; exit 1; }
  fi

  if ! aws --version 2> /dev/null; then
    # Install AWS CLI if it's not there
    echo "Error: Please install 'aws'. E.g."
    echo "  $ sudo easy_install awscli"
    echo "OR"
    echo "  $ curl \"https://s3.amazonaws.com/aws-cli/awscli-bundle.zip\" -o \"awscli-bundle.zip\""
    echo "  $ unzip awscli-bundle.zip"
    echo "  $ sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws"
    echo ""
    echo "You must run 'aws configure' after to setup permissions."
    exit 1;
  fi


  # This file changes locally in the dev env.  We need it in src ctrl for Travis 
  # to work but we want to ignore local changes.
  (cd $join_src_path && git update-index --assume-unchanged config/database.yml)

  cp -a ./beyondz-platform/docker-compose/config/* ./beyondz-platform/config/
  cp -a ./beyondz-platform/docker-compose/db/seeds.rb ./beyondz-platform/db/
  cp -a ./canvas-lms/docker-compose/config/* ./canvas-lms/config/
  cp -a ./rubycas-server/docker-compose/config/* ./rubycas-server/config/

  #docker-compose build --no-cache || { echo >&2 "Error: docker-compose build --no-cache failed."; exit 1; }
  docker-compose build || { echo >&2 "Error: docker-compose build --no-cache failed."; exit 1; }

  echo "Setting up Join development environment at: $join_src_path"
  cd $join_src_path

  # Load a dev database with real info (uses the most recent staging refresh db migrated to a dev db)
  aws s3 sync s3://beyondz-db-dumps/ db --exclude "*" --include "join_dev_db_dump_*"
  # db:load_dev expects the file to be located here:
  mv db/join_dev_db_dump_* db/dev_db.sql.gz
  docker-compose run --rm joinweb /bin/bash -c "bundle exec rake db:load_dev;" || { echo >&2 "Error: failed to load dev db."; exit 1; }
  # Necessary b/c the development RAILS_SECRET is different so we have to regenerate the password hashes
  docker-compose run --rm joinweb /bin/bash -c "bundle exec rails runner \"eval(File.read '/app/docker-compose/scripts/sanitize_passwords.rb')\"" || { echo >&2 "Error: failed to sanitize passworids in dev db."; exit 1; }
  # If you want to just use an empty database, you can replace the above steps to load the dev db with this:
  #docker-compose run --rm joinweb /bin/bash -c "bundle exec rake db:reset;" # Same as a db:create; db:migrate; db:seed, but also drops the DB first.


  echo "Setting up Canvas/Portal development environment at: $canvas_src_path"
  cd $canvas_src_path

  docker-compose run --rm canvasweb /bin/bash -c "bundle install" || { echo >&2 "Error: bundle install failed."; exit 1; }
  docker-compose run --rm canvasweb /bin/bash -c "npm install" || { echo >&2 "Error: npm install failed"; exit 1; }

  # Load a dev database with real info (uses the most recent staging refresh db migrated to a dev db)
  # Note: the access tokens, URLs, etc have been updated for use with dev.  The Join configuration has been
  # set to match.
  aws s3 sync s3://beyondz-db-dumps/ db --exclude "*" --include "lms_dev_db_dump_*"
  # db:load_dev expects the file to be located here:
  mv db/lms_dev_db_dump_* db/dev_db.sql.gz
  docker-compose run --rm canvasweb /bin/bash -c "bundle exec rake db:reset_encryption_key_hash;" # Required for a second run
  docker-compose run --rm canvasweb /bin/bash -c "bundle exec rake db:load_dev;" || { echo >&2 "Error: failed to load dev db."; exit 1; }
  # If you want to just use an empty database, you can replace the above steps to load the dev db with this:
  #docker-compose run --rm canvasweb /bin/bash -c "bundle exec rake db:create; bundle exec rake db:migrate; echo 'Choose whatever email/password/name you want for your local Canvas'; bundle exec rake db:initial_setup;"

  docker-compose run --rm canvasweb /bin/bash -c "bundle exec rake canvas:compile_assets" || { echo >&2 "Error: bundle exec rake canvas:compile_assets failed."; exit 1; }

  echo "Setting up SSO development environment at: $sso_src_path"
  cd $sso_src_path

  # OK, we're all set.  Let's start this bad boy.
  docker-compose up -d || { echo >&2 "Error: docker-compose up failed. A possible cause is that files use Windows newlines \(CRLF\). Check that all files in the docker-compose directory use Unix newlines \(LF\)."; exit 1; }


elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  # GNU/Linux platform
  echo "ERROR: setup script not written for Linux.  Please write it!"
  exit 1;
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  # Windows NT platform
  echo "ERROR: setup script not written for Windows.  Please write it!"
  exit 1;
fi

echo "Setup complete!  Please start a new shell to get your environment variables"
