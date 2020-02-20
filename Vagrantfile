# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :pam => {
        :box_name => "centos/7",
        :ip_addr => '192.168.12.5'
  }
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

      config.vm.define boxname do |box|

          box.vm.box = boxconfig[:box_name]
          box.vm.host_name = boxname.to_s

          box.vm.network "private_network", ip: boxconfig[:ip_addr]

          box.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "200"]
          end
          
          box.vm.provision "shell", inline: <<-SHELL
            mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
            sed -i '65s/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
            systemctl restart sshd
            groupadd admin
            useradd -m -s /bin/bash user1 && useradd -m -s /bin/bash user2 && useradd -m -s /bin/bash user3
            gpasswd -a user1 admin && gpasswd -a user2 admin && gpasswd -a root admin && gpasswd -a vagrant admin
            echo "Otus2020"| passwd --stdin user1 && echo "Otus2020" | passwd --stdin user2 && echo "Otus2020" | passwd --stdin user3
            chmod +x /vagrant/login.sh
            cp /vagrant/login.sh /usr/local/bin/login.sh
            sed -i '/pam_nologin.so/ a\ account    required     pam_exec.so \/usr\/local\/bin\/login.sh' /etc/pam.d/sshd
          SHELL
      end
  end
end
