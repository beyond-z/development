#!/bin/zsh

if ! heroku --version &> /dev/null; then
  # Install Heroku CLI if it's not there
  echo "Error: Please install the heroku cli. E.g."
  echo "https://devcenter.heroku.com/articles/heroku-cli#download-and-install"
  echo ""
  echo "You MUST run 'heroku login' after to authenticate."
  exit 1;
fi
