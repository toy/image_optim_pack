Vagrant.configure('2') do |config|
  # don't mess with keys
  config.ssh.insert_key = false

  # doesn't make sense to check updates for local boxes
  config.vm.box_check_update = false

  # there are no guest additions
  config.vm.provider 'virtualbox' do |vb|
    vb.check_guest_additions = false
    vb.customize ['modifyvm', :id, '--groups', '/image_optim']
  end

  # handle manually using rsync
  config.vm.synced_folder '.', '/vagrant', disabled: true

  {
    'linux-x86_64'  => 'boxes/centos-amd64.box',
    'linux-i686'    => 'boxes/centos-i386.box',
  }.each do |name, location|
    config.vm.define name do |machine|
      machine.vm.hostname = name.gsub('_', '-')
      machine.vm.box = location

      machine.vm.provision :shell, inline: case name
      when /^linux/
        <<-SH
          set -ex
          if command -v apt-get; then
            apt-get update
            apt-get -y install rsync ntpdate make wget gcc g++ chrpath perl pkg-config autoconf automake libtool nasm cmake
          else
            yum -y install rsync ntpdate make wget gcc gcc-c++ chrpath perl pkg-config autoconf automake libtool nasm cmake
          fi
        SH
      end

      machine.vm.provision :shell, inline: <<-SH
        set -ex
        mkdir -p /vagrant
        chown vagrant:vagrant /vagrant
      SH
    end
  end
end
