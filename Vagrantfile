Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision :shell, path: "vagrant/bootstrap.sh"
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
  end
  config.vm.define "quorum-node1" do |quorum_node|
    quorum_node.vm.network "private_network", ip: "192.168.33.11"
  end
  config.vm.define "quorum-node2" do |quorum_node|
    quorum_node.vm.network "private_network", ip: "192.168.33.12"
  end
  config.vm.define "quorum-node3" do |quorum_node|
    quorum_node.vm.network "private_network", ip: "192.168.33.13"
  end
  config.vm.define "quorum-node4" do |quorum_node|
    quorum_node.vm.network "private_network", ip: "192.168.33.14"
  end
  config.vm.define "quorum-node5" do |quorum_node|
    quorum_node.vm.network "private_network", ip: "192.168.33.15"
  end
end
