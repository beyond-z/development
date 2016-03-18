This is a top-level repository that helps get a Braven development
environment setup on your local machine.

The list of repositories that this sets up is located in [repos.txt](repos.txt)

# Getting Started
First, [Fork this repository](https://github.com/beyond-z/development#fork-destination-box) **and** all repositories in the [repos.txt](repos.txt) file.

Then, setup your local development environment
 ```Shell 
cd [some_root_src_dir]
git clone https://github.com/[your_username]/development.git development
cd development
./setup.bat
```

# Connecting to services
All services are available at the ```VIRTUAL_HOST``` specified in
[docker-compose.yml](docker-compose.yml).  Examples:
* Canvas is at [http://canvas.docker](http://canvas.docker)
* Join is at [http://join.docker](http://join.docker)
* Single Sign-on is at [http://sso.docker](http://sso.docker)

By default, the build scripts add two users:
* join.admin@bebraven.org - access to the Join server's admin dashboard
* admin@beyondz.org - access to the Canvas admin account
   Note: at the time of writing, if you don't specify admin@beyondz.org
   as the Canvas admin when running ./setup.bat then you have to login with
   whatever account you did create at
   http://canvas.docker/login?canvas_login=1 and add that user.

# Tips and Tricks
## Development
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
git commit -m "A descriptive message telling what you changed so that
people can glance back through commits and find ones that may be
applicable"
git push origin [some_branch]
```

Login to github and open Pull Request against the parent beyond-z
repository that you forked from.

Once the Pull Request is merged back to staging, you can delete your
development branch:
```Shell
git checkout staging; git pull upstream staging; git branch -d
[some_branch]
```
## Docker
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
