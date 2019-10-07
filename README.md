This is a top-level repository that helps get a Braven development
environment setup on your local machine.

The list of repositories that this sets up is located in [repos.txt](repos.txt)

# Getting Started
First, [Fork this repository](https://github.com/beyond-z/development#fork-destination-box) **and** all repositories in the [repos.txt](repos.txt) file.

Ask your team lead to setup an AWS account that can access the proper development S3 buckets.  Once you have an account created, add the key and secret to your `~/.bash_profile` like so:
```
export AWS_ACCESS_KEY_ID=<your_key>
export AWS_SECRET_ACCESS_KEY=<your_secret>
``` 

Also add the Salesforce Sandbox related environment variables documented here: (https://github.com/beyond-z/beyondz-platform/blob/staging/README.md)

 ```Shell 
cd [some_root_src_dir]
git clone https://github.com/[your_username]/development.git development
cd development
./setup.sh
```

After the initial setup, you may have to restart each app after the databases have all loaded b/c we haven't yet solved the timing issue for the app to wait and retry until the DB is up.

# Connecting to services
All services are available at the service name specified in the 
[docker-compose.yml](docker-compose.yml) inside that repository.  Examples:
* Canvas is at [http://canvasweb](http://canvasweb)
* Canvas JS/CSS is at [http://cssjsweb/](http://cssjsweb/bz_custom.css)
* Join is at [http://joinweb](http://joinweb)
* Single Sign-on is at [http://ssoweb](http://ssoweb)
* Kits is at [http://kitsweb](http://kitsweb)

# Development
We use a standard fork/branch/pull-request workflow. To make changes,
always start with that repository's ```staging``` branch and create your
own branch from it.  Here is an example of making a change to the Join
server (aka beyondz-platform):
```Shell
cd development/beyondz-platform
git pull upstream staging
git push staging origin
git checkout -b [some_branch]
```

Then make your code changes.  To get them back into the main code,
submit a pull request:

```Shell
git add [your_changed_files]
git commit -v
# Enter A descriptive title of the change on the first line
#
# Followed by more details, especially details on how to test it!
git push origin [some_branch]
```

Login to github and open Pull Request against the parent beyond-z
repository that you forked from.

Once the Pull Request is merged back to staging, you can delete your
development branch:
```Shell
git checkout staging; git pull upstream staging; git branch -d
[some_branch]; git push origin staging
```

# Tips and Tricks
I highly recommend you add this to your `~/.bash_profile`
```
# If you're in the app root of any of our repos, these aliases let you 
# manage the dev env easy
alias devrs='./docker-compose/scripts/restart.sh'
alias devrb='./docker-compose/scripts/rebuild.sh'
alias devdb='./docker-compose/scripts/dbconnect.sh'
alias devc='./docker-compose/scripts/console.sh'
alias deva='./docker-compose/scripts/appconnect.sh'
```

Also, if you add this as well, it will show the current branch you're on in the shell. E.g.
`~/src/development/beyondz-platform(current_branch_name) $`
```
# Adds the current git branch in parentheses to the shell prompt.  E.g. ~/src/my-repo(master)$
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
  }
PS1="\w(\$(parse_git_branch)) $ "
```

# OBSOLETE FROM HERE ON DOWN. UPDATE ME!!

## Docker
There are two modes to setup your Docker development environment.  The default lightweight environment uses ```setup.bat``` and ```start.bat``` which only setup and start the basic services.  However, if you want to develop something on the public Braven website or Braven Help, use ```setupall.bat``` and ```startall.bat``` to run the full dev env.  This is done because running all the services is very resource intensive on your machine.  In fact, the development environment is so resource intensive that you probably want to run ```stop.bat``` when you are not actively developing and then ```start.bat``` when you are ready to work again.

Each repository has some helpful scripts to interact with your local
service using docker in ```[some_repo]/docker-compose/scripts```.  E.g.
you can restart the ```canvas-lms``` server using ```canvas-lms/docker-compose/scripts/restart.bat```

You can run the same commands directly using ```docker``` and ```docker-compose```.
Note: all service names are located in [docker-compose.yml](docker-compose.yml) E.g. the Join web server service is named ```joinweb```

Here are some examples:
* See the status of your containers: ```docker ps```
* Get the server logs from a service: ```docker-compose logs
  [service_name]```
* Restart a service: ```docker-compose restart [service_name]```
* Connect to a shell for a service: ```docker-compose run --rm
  [service_name] /bin/bash```
* Run a rake command for a service: ```docker-compose run --rm
  [service_name] bundle exec rake [rake_task]```
