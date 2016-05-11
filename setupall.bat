#!/bin/bash

./setup.bat

braven_src_path="$( cd $bash_src_path; cd braven && pwd )"
osqa_src_path="$( cd $bash_src_path; cd osqa && pwd )"

if [ "$(uname)" == "Darwin" ]; then
  # OS X platform

  cp -a ./braven/docker-compose/config/wp-config.php ./braven/wp-config.php
  cp -a ./osqa/docker-compose/config/settings_local.py ./osqa/settings_local.py

  docker-compose -f ./docker-compose-optional.yml build || { echo >&2 "Error: docker-compose -f ./docker-compose-optional.yml build failed."; exit 1; }

  echo "Setting up Braven development environment at: $braven_src_path"
  cd $braven_src_path

  # Load a dev database with real info (uses the most recent production db migrated to a dev db)
  # Note: the URLs, passwords, etc have been updated for use with dev before they were uploaded to
  # the S3 bucket using the braven/docker-compose/scripts/migrate_prod_db.bat script on the updraftplus DB backup.
  # Also, the braven-wp-content*.zip file was created to mimic the wp-content folder 
  # using the updraftplus backups on dropbox (/<BeyondZ Dropbox>/Apps/UpdraftPlus/BeBraven
  tmp_dir=docker-compose/tmp
  mkdir $tmp_dir
  rm $tmp_dir/braven*
  aws s3 sync s3://beyondz-db-dumps/ $tmp_dir --exclude "*" --include "braven-*"
  mv $tmp_dir/braven-wp-content*.zip $tmp_dir/braven-wp-content.zip
  unzip -o $tmp_dir/braven-wp-content.zip || { echo >&2 "Error: failed extracting braven-wp-content.zip pulled from Amazon S3 into wp-content folder"; exit 1; }
  find ./wp-content -type f -print0 | xargs -0 chmod 644
  mv $tmp_dir/braven-dev-db*.gz $tmp_dir/braven-dev-db.gz
  gzip -cd $tmp_dir/braven-dev-db.gz | docker-compose run --rm bravendb mysql -h bravendb -u wordpress "-pwordpress" wordpress || { echo >&2 "Error: failed loading development db for braven"; exit 1; }
  rm -rf $tmp_dir
  echo "http://braven.docker/wp-admin username/password is: beyondz/test1234"

  echo "Setting up OSQA development environment at: $osqa_src_path"
  cd $osqa_src_path
  cat docker-compose/config/braven_settings.sql | docker-compose run --rm helpweb psql -h helpdb -U root -d osqa
  echo "IMPORTANT: You can login to Braven Help with any Braven Portal user and it will initialize them.  However, THE FIRST one you do this with becomes the Braven Help admin!!!"

  # OK, we're all set.  Let's start this bad boy.
  docker-compose -f ./docker-compose-optional.yml up -d || { echo >&2 "Error: docker-compose -f ./docker-compose-optional.yml up failed. A possible cause is that files use Windows newlines \(CRLF\). Check that all files in the docker-compose directory use Unix newlines \(LF\)."; exit 1; }


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
