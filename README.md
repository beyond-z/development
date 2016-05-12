This is a top-level repository that helps get a Braven development
environment setup on your local machine.

The list of repositories that this sets up is located in [repos.txt](repos.txt)

# Getting Started
First, [Fork this repository](https://github.com/beyond-z/development#fork-destination-box) **and** all repositories in the [repos.txt](repos.txt) file.

Ask your team lead to setup an AWS account that can access the proper development S3 buckets.  Once you have an account created then setup your local development environment using the commands below.  Note: the first time it will fail with instructions on how to configure your AWS account.
 ```Shell 
cd [some_root_src_dir]
git clone https://github.com/[your_username]/development.git development
cd development
./setup.bat
./start.bat
```

# Connecting to services
All services are available at the ```VIRTUAL_HOST``` specified in
[docker-compose.yml](docker-compose.yml).  Examples:
* Canvas is at [http://canvas.docker](http://canvas.docker)
* Join is at [http://join.docker](http://join.docker)
* Single Sign-on is at [http://sso.docker](http://sso.docker)
* Public facing Braven website is at [http://braven.docker](http://braven.docker)
* Braven Help is at [http://help.docker](http://help.docker)

The two main admin users to be aware of are the following.  Ask your team-mate what the passwords are.
* join.admin@bebraven.org - access to the Join server's admin dashboard.  Login [here](http://join.docker/admin).
* admin@beyondz.org - access to the Portal admin account.  Login [here](http://canvas.docker)

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
