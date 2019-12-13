#!/bin/sh -x

cd /vagrant

if [ ! -f env.local ]; then
    cp env.local.example env.local
    cat <<EOF >> env.local

# override with values needed for vagrant
export HOSTNAME_FQDN='${VM_HOSTNAME}.$VM_DOMAIN'
EOF
else
    echo "existing env.local file, not overriding"
fi
