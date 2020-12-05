set -ex

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

yum -y install wget

# Make ssh faster by not waiting on DNS
echo "UseDNS no" >> /etc/ssh/sshd_config

# Vagrant specific
date > /etc/vagrant_box_build_time

# Add vagrant user
/usr/sbin/groupadd vagrant
/usr/sbin/useradd vagrant -g vagrant -G wheel
echo "vagrant"|passwd --stdin vagrant
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

# Installing vagrant keys
mkdir -pm 700 /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

yum -y clean all

# Zero out the free space to save space in the final image
dd if=/dev/zero of=/filler bs=1M || rm /filler
