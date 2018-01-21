# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"

  #config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.define :redis1 do |m|
    m.vm.hostname = "redis1"
    m.vm.provider "virtualbox" do |v|
      v.memory = 512
    end
    m.vm.network :private_network, ip: "192.168.33.11"
    m.vm.provision "shell", path: "setup.sh"
  end

  config.vm.define :redis2 do |m|
    m.vm.hostname = "redis2"
    m.vm.provider "virtualbox" do |v|
      v.memory = 512
    end
    m.vm.network :private_network, ip: "192.168.33.12"
    m.vm.provision "shell", path: "setup.sh"
  end

  config.vm.define :client do |m|
    m.vm.hostname = "client"
    m.vm.provider "virtualbox" do |v|
      v.memory = 512
    end
    m.vm.network :private_network, ip: "192.168.33.20"
    m.vm.provision "shell", path: "setup-client.sh"
  end
end
