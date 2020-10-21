#!/bin/zsh

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