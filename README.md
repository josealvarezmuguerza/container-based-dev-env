# container-based-dev-env

Linux home for programmers based on docker containers. 

If you are a hater like me on installing new tools once you jump into a new project, you will love solution! It wraps in containers each and every app / tool / framework / library you need in your daily job keeping your machine host OS clean as day-zero :sparkles: .

# setup
Firstly, identify which shell command-line interpreter your Terminal uses. In my case I use `bash`, so at the end of `${HOME}/.bashrc` file add these two lines:

```
# enable docker runs commands 
source $HOME/bin/.docker-runs.sh
```
This enable your custom docker commands everytime you open a new Terminal

Then, copy file `.docker-runs.sh` under `${HOME}/bin/`.


# usage


### Quick example:
```
ubuntu$ mysqld
Existing abandoned mysqld container. Removing...
27e8cd7934fdfced42d5a042eb41cbdbbb0d5c231d7d8bcb527b82b3bcdd29f4
... archive removed!
Launching new mysqld container...
9e60441bc2ec34dd5c17a76e6299383860740c93dd159b525e53547de4b4fcf9
``` 

# workflow 
1. It first verifies the container is not already up & running, in that case it suggests you to reuse it
2. Later it verifies the existence of abandoned container with same name, in that case it remove the exited and obsolete container.
3. Launches a new desired container


# author
@Josealvarezmuguerza in collaboration of community who kindly shared some dockerfiles.  