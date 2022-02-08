#!/bin/bash

YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
NORMAL=$(tput sgr0)

# list of all variables to be substituted in templates
VARS='
  $HOSTNAME_FQDN
  $INITIAL_ROOT_PASSWORD
  $GITLAB_WEB_URL
  $GITLAB_TOKEN
'

# list of vars to be substituted in template but they do not have to be set in
# env.local
OPTIONAL_VARS='
'

# we switch to the real directory of the script, so it still works when used from $PATH
# tip: ln -s /path/to/docker-compose-wrapper.sh ~/bin/gitlab-compose
cd $(dirname $(readlink -f $0 || realpath $0))

# we source local configs, if present
# we don't use usual .env filename, because docker-compose uses it
[[ -f env.local ]] && source env.local

for i in ${VARS}
do
  v="${i#$}"
  if [[ -z "${!v}" ]]
  then
    echo "${RED}Error${NORMAL}: Required variable $v is not set. Check env.local file."
    exit 1
  fi
done

if [[ ! -f docker-compose.yml ]]
then
  echo "Error, this script must be ran from the folder containing the docker-compose.yml file"
  exit 1
fi

## we apply all the templates
find ./config -name '*.template' -print0 |
  while IFS= read -r -d $'\0' FILE
  do
    DEST=${FILE%.template}
    cat ${FILE} | envsubst "$VARS" | envsubst "$OPTIONAL_VARS" > ${DEST}
  done

if [[ $1 == "up" ]]; then
  # no error if already exist
  # create externally so nothing will delete these data volume automatically
  docker volume create gitlab_data_persistence
  docker volume create gitlab_logs_persistence
  docker volume create gitlab_config_persistence
fi

COMPOSE_CONF_LIST="-f docker-compose.yml"
for adir in ${EXTRA_CONF_DIRS}; do
  if [ -f "$adir/docker-compose-extra.yml" ]; then
    COMPOSE_CONF_LIST="${COMPOSE_CONF_LIST} -f $adir/docker-compose-extra.yml"
  fi
done
echo "COMPOSE_CONF_LIST=${COMPOSE_CONF_LIST}"

docker-compose ${COMPOSE_CONF_LIST} $*
ERR=$?

# execute post-compose function if exists and no error occurred
type post-compose 2>&1 | grep 'post-compose is a function' > /dev/null
if [[ $? -eq 0 ]]
then
  [[ ${ERR} -gt 0 ]] && { echo "Error occurred with docker-compose, not running post-compose"; exit $?; }
  post-compose $*
fi


#while [[ $# -gt 0 ]]
#do
#  if [[ $1 == "up" ]]; then
#    # post docker-compose up processing
#  fi
#  shift
#done


# vi: tabstop=8 expandtab shiftwidth=2 softtabstop=2
