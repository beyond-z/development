#!/bin/zsh

echo "Checking if the AWS ENV vars are setup"
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "The AWS ENV vars arent setup. TODO: add these to your .bash_profile"
  echo '  export AWS_ACCESS_KEY_ID=<yourkey>'
  echo '  export AWS_SECRET_ACCESS_KEY=<yoursecretkey>'
  exit 1
else
  echo "You good!"
fi
