# docker-postgresql

A Dockerfile that produces a container that will run [PostgreSQL][postgresql] on centos6

[postgresql]: http://www.postgresql.org/

The work is based on famous [paintedfox/postgresql](https://github.com/Painted-Fox/docker-postgresql), I forked to have it for centos based

## Changes ##

* CentOS 6.5 is used as latest ( CentOS 6.4 has small issues for `/etc/sysconfig/network` is abcent)
* SSH daemon is added 
* pwgen is removed 
* /initdb for first run, no database is created during initialized

## Image Creation

This example creates the image with the tag `larrycai/postgresql`, but you can
change this to use your own username.

```
$ docker build -t="larrycai/postgresql" .
```

Alternately, you can run the following if you have *make* installed.

```
$ make
```

You can also specify a custom docker username like so:

```
$ make DOCKER_USER=larrycai
```

## Container Creation / Running

The PostgreSQL server is configured to store data in `/data` inside the
container.  You can map the container's `/data` volume to a volume on the host
so the data becomes independant of the running container. 

(TODO) There is also an additional volume at `/var/log/postgresql` which exposes PostgreSQL's logs.

This example uses `/tmp/postgresql` to store the PostgreSQL data, but you can
modify this to your needs.

When the container runs, it creates a superuser with a random password.  You
can set the username and password for the superuser by setting the container's
environment variables.  This lets you discover the username and password of the
superuser from within a linked container or from the output of `docker inspect
postgresql`.

If you set DB=database_name, when the container runs it will create a new
database with the USER having full ownership of it.

### Initialize the db 

In order to use new data, the container needs to be initialzed

``` shell
$ mkdir -p /tmp/postgresql
$ docker run -p 5432:5432 --name="postgresql" -i -t -v /tmp/postgresql:/data -e DB="db" -e USER="user" -e PASS="user" larrycai/postgresql /initdb
```

Actually it moves the initialized the db to new volume 

``` shell
cp -R /var/lib/pgsql/9.3/data/* $DATA_DIR
```

if you want to re-initialized (reset) the db, please remove `/tmp/postgresql/db_is_initialzed`

### Normal startup

``` shell
$ mkdir -p /tmp/postgresql
$ docker run -d --name="postgresql" -p 5432:5432 -P -v /tmp/postgresql:/data larrycai/postgresql
```

You can also specify a custom port to bind to on the host, a custom data
directory, and the superuser username and password on the host like so:


## Connecting to the Database

To connect to the PostgreSQL server, you will need to make sure you have
a client.  You can install the `postgresql-client` on your host machine by
running the following (Ubuntu 12.04LTS):

``` shell
$ sudo apt-get install postgresql-client
```

## Linking with the Database Container

You can link a container to the database container.  You may want to do this to
keep web application processes that need to connect to the database in
a separate container.

To demonstrate this, we can spin up a new container like so:

``` shell
$ docker run -t -i --link postgresql:db ubuntu bash
```

This assumes you're already running the database container with the name
*postgresql*.  The `--link postgresql:db` will give the linked container the
alias *db* inside of the new container.

From the new container you can connect to the database by running the following
commands:

``` shell
$ apt-get install -y postgresql-client
$ psql -U postgres \
       -h "$DB_PORT_5432_TCP_ADDR" \
       -p "$DB_PORT_5432_TCP_PORT"
```

If you ran the *postgresql* container with the flags `-e USER=<user>` and `-e
PASS=<pass>`, then the linked container should have these variables available
in its environment.  Since we aliased the database container with the name
*db*, the environment variables from the database container are copied into the
linked container with the prefix `DB_ENV_`.

## Issues ##

* Locale problem: http://unix.stackexchange.com/questions/140299/locale-gen-command-in-centos6

# Reference

* http://www.linuxmental.com/how-to-install-postgresql-9-3-in-centos-rhel-linux
* http://tecadmin.net/install-postgresql-on-centos-rhel-and-fedora/
* http://www.davidghedini.com/pg/entry/install_postgresql_9_on_centos
* http://yum.postgresql.org/repopackages.php#pg93

several dockerfiles are referred
 
* https://github.com/allisson/docker-postgresql/blob/master/supervisord.conf
* https://github.com/Painted-Fox/docker-postgresql
* https://github.com/cthulhuology/docker-postgresql