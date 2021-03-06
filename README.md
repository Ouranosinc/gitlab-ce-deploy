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


## Vagrant instructions

Vagrant allows us to quickly spin up a VM to easily reproduce the runtime
environment for testing or to have multiple flavors of this deployment with
slightly different combinations of the parts all running simultaneously in
their respective VM, allowing us to see the differences in behavior.

See [`vagrant_variables.yml.example`](vagrant_variables.yml.example) for what's
configurable with Vagrant.

Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads), both the
platform and the extension pack, and
[Vagrant](https://www.vagrantup.com/downloads.html).

One time setup:
```
# Clone this repo and checkout the desired branch.

# Follow instructions and fill up infos in vagrant_variables.yml
cp vagrant_variables.yml.example vagrant_variables.yml
$EDITOR vagrant_variables.yml  # customize to your needs
```

Starting and managing the lifecycle of the VM:
```
# start everything, this is the only command needed to bring up the entire
# deployment
vagrant up

# get bridged IP address
vagrant ssh -c "ip addr show enp0s8|grep 'inet '"

# get inside the VM
# useful to manage the deployment as if Vagrant is not there
# and use docker-compose-wrapper.sh as before
# ex: cd /vagrant; ./docker-compose-wrapper.sh ps
vagrant ssh

# poweroff VM
vagrant halt

# delete VM
vagrant destroy

# reload Vagrant config if vagrant_variables.yml or Vagrantfile changes
vagrant reload

# provision again (because all subsequent vagrant up won't provision again)
# useful to test all provisionning scripts or to bring a VM at unknown state,
# maybe because it was provisioned too long ago, to the latest state.
# not needed normally during tight development loop
vagrant provision
```
