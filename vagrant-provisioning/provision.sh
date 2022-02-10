#!/bin/sh -x
#
# Test: VM_HOSTNAME=host VM_DOMAIN=dom.main ./vagrant-provisioning/provision.sh

cd /vagrant

if [ -f ./env.local ]; then
    # Get SSL_CERTIFICATE, SSL_CERTIFICATE_KEY from existing env.local.
    . ./env.local
fi

if [ ! -f "$SSL_CERTIFICATE" -a ! -f "$SSL_CERTIFICATE_KEY" ]; then
    # If both have bogus value, set appropriate one for Vagrant.
    SSL_CERTIFICATE="/home/vagrant/cert.pem"
    SSL_CERTIFICATE_KEY="/home/vagrant/key.pem"
fi

if [ ! -f env.local ]; then
    cp env.local.example env.local
    cat <<EOF >> env.local

# override with values needed for vagrant
export HOSTNAME_FQDN='${VM_HOSTNAME}.$VM_DOMAIN'
# Refine because GITLAB_WEB_URL depends on HOSTNAME_FQDN.
export GITLAB_WEB_URL="https://\${HOSTNAME_FQDN}"

export SSL_CERTIFICATE="$SSL_CERTIFICATE"
export SSL_CERTIFICATE_KEY="$SSL_CERTIFICATE_KEY"

EOF
else
    echo "existing env.local file, not overriding"
fi

if [ ! -f "$SSL_CERTIFICATE" -a ! -f "$SSL_CERTIFICATE_KEY" ]; then
    . ./env.local
    openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 \
        -keyout "$SSL_CERTIFICATE_KEY" \
        -out "$SSL_CERTIFICATE" \
	-subj "/C=CA/ST=Quebec/L=Montreal/O=RnD/CN=*.${VM_HOSTNAME}.$VM_DOMAIN"
else
    echo "existing '$SSL_CERTIFICATE' or '$SSL_CERTIFICATE_KEY' file, not overriding"
fi


sudo apt update
sudo apt install docker.io docker-compose

# Add current user to group docker to not have to always do 'sudo docker'
sudo usermod -a -G docker $USER
if [ -n "`df -h | grep ^vagrant`" ]; then
    # inside a vagrant box, add user 'vagrant' to group docker for the same reason
    # $USER was 'root', not 'vagrant', during provisionning step
    sudo usermod -a -G docker vagrant
fi


# Start the whole stack.
./docker-compose-wrapper.sh up -d
