# gitlab-ce-deploy
Deploy gitlab-ce using docker-compose

## Usage

Ensure you have [docker](https://www.docker.com/) and
[docker-compose](https://docs.docker.com/compose/) installed on your Linux
host.

One time setup
```
cp env.local.example env.local
$EDITOR env.local  # customize to your needs
```

Start Gitlab
```
./docker-compose-wrapper.sh up -d
```

Access Gitlab at
http://${HOSTNAME_FQDN},
those variables are from your customized `env.local` file.

`docker-compose-wrapper.sh` is just a wrapper around `docker-compose` so all valid
docker-compose use-cases and command-line options are supported.

Upgrade instructions
```shell
./docker-compose-wrapper.sh down -v  # only delete anonymous data volume
git pull
# update env.local with new variables from env.local.example if needed
scripts/backup-gitlab.sh  # backup to /tmp
./docker-compose-wrapper.sh up -d
```


## Data Persistance

This deployment uses named docker volume for data persistance.  Three named
volume will be created and will survive `./docker-compose-wrapper.sh down -v`:

* gitlab_data_persistence
* gitlab_logs_persistence
* gitlab_config_persistence
