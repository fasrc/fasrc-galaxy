Running Galaxy in a container
-----------------------------

There's a Docker container [here](https://hub.docker.com/r/bgruening/galaxy-stable) which sets up a basic galaxy environment, including the galaxy web application code, nginx, postgresql, and some other associated tools and services.

From that container, I built another container with an updated version of R and the galaxy tools currently installed on hutlab14. There are some tool dependency issues still to work out, but you should be able to follow this quick guide to test locally.

Get docker
----------

If you're using a linux machine that can run docker natively, install the relevant tools for your OS. If you're running OS X, install based on the [docker-machine](https://docs.docker.com/machine/) documentation. This is what I've used to develop locally and push changes to [docker hub](https://hub.docker.com).


Run the modified galaxy image
-----------------------------

With the docker tools installed, run the container like so:

`docker run -d -p 8081:80 -p 8021:21 -p 9002:9002 --name galaxy -e "NONUSE=proftp,reports,slurmd,slurmctld" fasrc/fasrc-galaxy:latest`

The source for this [container](https://hub.docker.com/r/fasrc/fasrc-galaxy) is on github [here](https://github.com/fasrc/fasrc-galaxy). You can download the source Dockerfile, edit it and submit changes as pull requests via github, or you can replicate the same thing in your own repo and create a new container with the changes you need.

Installing R modules or other dependencies
------------------------------------------

R is local to the container, so for testing, deal with the module installs as you would normally. R is also locally installed on hutlab14. The setup is the same, but the underlying OS is different.

Get a shell inside the container via `docker exec -ti galaxy /bin/bash` and test installing any dependencies. The CRAN apt repo is defined, so it's a good idea to check whether a package is available for the module you need with an: `apt-cache search r-modulename`

If there isn't a package available for the module you need, you can install the dependencies manually.

You'll see in the Dockerfile that some of these R packages are installed when building the container. Any missing dependency should end up in the Dockerfile so that no manual intervention is required when deploying the container.

When you add anything to the Dockerfile and want to enable these changes in production, we'll need to ensure the resulting container is pulled and running on hutlab15.

Where are local data stored, like `/usr/local/galaxy-dist/database/files` on the existing VM?
---------------------------------------------------------------------------------------------

Data are stored here inside the container: /export/galaxy-central/database/files

This directory is actually mounted within the container from the host. Right now, the space corresponds to the local (virtual disk) path here: /var/local/galaxy/galaxy-central. We can mount network storage at this or any other location to ensure the files are stored outside of both the container and the virtual machine.

How does one restart services?
------------------------------

The easiest way to restart one of the core galaxy services is to use the supervisor web interface listening to port 9002 on the vm. Port 9002 is available to you while connected via VPN but will not be exposed to the outside world. From the web interface, you can stop/start the following services and tail the logs:

  - docker (disabled service)
  - galaxy_nodejs_proxy (disabled service)
  - galaxy_web
  - galaxy:handler0
  - galaxy:handler1
  - nginx
  - postgresql
  - proftpd (disabled service)
  - reports (disabled service)

Aside from that, you can stop/start/restart services via `supervisorctl` from within a shell session in the container.


How does one upgrade the db schema after a galaxy upgrade?
----------------------------------------------------------

This should be relatively easy. You can do this from within a shell in the container or via `docker run`:

  `root@ad4f7181b928:/galaxy-central# sh manage_db.sh -c /etc/galaxy/galaxy.ini upgrade`


How does one point the container to an external db host?
--------------------------------------------------------

You can do this by setting the `GALAXY_CONFIG_DATABASE_CONNECTION` environment variable when running the container. This corresponds to the `database_connection` configuration line in the galaxy.ini file. By default, the container assumes it will use the local postgresql service inside the container.
