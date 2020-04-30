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

After the initial setup, you may have to *restart each app* one time after the databases have all loaded b/c we haven't yet solved the timing issue for the app to wait and retry until the DB is up.

*Note: this `setup.sh` script is really only meant for initial setup. Once you have run it once, it may not do what you expect b/c it doesn't rebuild the environment. After initial setup, use the local `docker-compose/scripts/rebuild.sh` for any apps that you want to cleanly pull in all the latest changes.*

# Connecting to services
All services are available at the service name specified in the 
[docker-compose.yml](docker-compose.yml) inside that repository.  Examples:
* Canvas is at [http://canvasweb](http://canvasweb)
* Canvas JS/CSS is at [http://cssjsweb/](http://cssjsweb/bz_custom.css)
* Join is at [http://joinweb](http://joinweb)
* Single Sign-on is at [http://ssoweb](http://ssoweb)
* Kits is at [http://kitsweb](http://kitsweb)
* Braven Platform is at [http://platformweb](http://platformweb)
* BeBraven.org is at [http://bravenweb](http://bravenweb)

# Development
We use a standard [fork/branch/pull-request workflow](http://nathanhoad.net/git-workflow-forks-remotes-and-pull-requests). To make changes, always start with that repository's ```staging``` branch and create your own branch from it.  Here is an example of making a change to the **Join** server (aka beyondz-platform):
```Shell
cd development/beyondz-platform
git pull upstream staging
git checkout -b [some_branch]
```

Then make your code changes. You can see your changes take effect in the browser by going to [http://joinweb](http://joinweb).

See below for some tips and tricks to manage the Docker environment if you're not seeing your change take effect or if you need to get an updated database or content to work from.

Once you're changes look good, commit them and open a pull request. Also see note below about multiple commits.

```Shell
git add [your_changed_files]
git commit -v
# Enter A descriptive title of the change on the first line
#
# Followed by more details, especially details on how to test it!
git push origin [some_branch]
```

To get them back into the main codebase login to [github](https://github.com) in your browser and submit a Pull Request against the `staging` branch of the `beyond-z` repo you forked.

Choose a couple fellow developers and request a code review. Once at least one developer approves your pull request, you can merge it and delete the branch on [github](https://github.com). Then you're ready to start working on your next feature, so do some cleanup first and then start this flow all over again!
```Shell
git checkout staging; git pull upstream staging; git branch -d [some_branch]; git push origin staging
```
*Note*: You can commit multiple times to your branch before you are ready to open a Pull Request. You can also keep committing to your branch even after the Pull Request has been opened as long as it hasn't been merged yet. Just remember to push your commits to `origin` for them to be included in the Pull Request.


# Tips and Tricks
## Docker
I highly recommend you add this to your `~/.bash_profile` so that you can restart your docker container, connect to the container, the database, the console, or rebuild your container using commands like `devrs`, `deva`, etc for the app that you are currently working in.
```
# If you're in the app root of any of our repos, these aliases let you 
# manage the dev env easy
alias devrs='./docker-compose/scripts/restart.sh'
alias devrb='./docker-compose/scripts/rebuild.sh'
alias devdb='./docker-compose/scripts/dbconnect.sh'
alias devc='./docker-compose/scripts/console.sh'
alias deva='./docker-compose/scripts/appconnect.sh'
alias devl='docker-compose logs -f
```

If you restart your computer or restart the Docker daemon and your containers are stopped, you can bring them all back up by running `up.sh` from the `development` directory. You'll know you need to do this if you run `docker container ls` and don't see something like:

```
STATUS              PORTS                            NAMES
Up 40 minutes       0.0.0.0:3000->3000/tcp           canvas-lms_canvasweb_1
Up 40 minutes       6379/tcp                         canvas-lms_canvasredis_1
Up 40 minutes       5432/tcp                         canvas-lms_canvasdb_1
Up 2 days           80/tcp, 0.0.0.0:3005->3005/tcp   kits_kitsweb_1
Up 2 days           3306/tcp, 33060/tcp              kits_kitsdb_1
Up 2 days           0.0.0.0:3001->3001/tcp           beyondz-platform_joinweb_1
Up 2 days           5432/tcp                         beyondz-platform_joindb_1
Up 9 days           0.0.0.0:3002->3002/tcp           rubycas-server_ssoweb_1
Up 9 days           5432/tcp                         rubycas-server_ssodb_1
Up 9 days           0.0.0.0:80->80/tcp               nginx-dev_nginx_dev_1
Up 10 days          0.0.0.0:3004->3004/tcp           canvas-lms-js-css_cssjsweb_1
```

Most changes you make to the code should just automatically take effect, but sometimes you'll need to restart or rebuild your container if you touch something that is built into the container image itself using `devrs` or `devrb`.
## General
Also, if you add this as well, it will show the current branch you're on in the shell. E.g.
`~/src/development/beyondz-platform(current_branch_name) $`
```
# Adds the current git branch in parentheses to the shell prompt.  E.g. ~/src/my-repo(master)$
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
  }
PS1="\w(\$(parse_git_branch)) $ "
```
