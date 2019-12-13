# -*- mode: ruby -*-
# vi: set ft=ruby tabstop=8 expandtab shiftwidth=2 softtabstop=2 :

require 'yaml'
config_file=File.expand_path(File.join(File.dirname(__FILE__), 'vagrant_variables.yml'))
settings=YAML.load_file(config_file)


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vagrant.plugins = ["vagrant-disksize", "vagrant-vbguest"]

  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/bionic64"
  config.vm.define settings['hostname']
  config.vm.hostname = settings['hostname']
  # thin provisioning, won't take 40G upfront
  config.disksize.size = settings.fetch('disksize', '40GB')

  # bug https://github.com/hashicorp/vagrant/issues/3341 still happening as of
  # 2019-10-31 with VirtualBox 6.0.12
  config.vbguest.auto_update = false

  # bridge networking to get real DNS name on local network
  if settings.has_key?('hostip')
    if settings.has_key?('network_bridge')
      config.vm.network "public_network", ip: settings['hostip'], bridge: settings['network_bridge']
    else
      config.vm.network "public_network", ip: settings['hostip']
    end
  else
    if settings.has_key?('network_bridge')
      config.vm.network "public_network", bridge: settings['network_bridge']
    else
      config.vm.network "public_network"
    end
  end

  config.vm.provider "virtualbox" do |v|
      v.memory = settings.fetch('memory', 4096)
      v.cpus = settings.fetch('cpus', 2)
  end

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y docker.io docker-compose
    adduser vagrant docker
  SHELL

  config.vm.provision :shell, path: "vagrant-provisioning/provision.sh",
                              env: {"VM_HOSTNAME" => settings['hostname'],
                                    "VM_DOMAIN" => settings['domain'],
                                    }

end
