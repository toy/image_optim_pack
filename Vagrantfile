Vagrant.require_version '!= 1.8.5' # OpenBSD can't be halted in 1.8.5

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
    'freebsd-amd64' => 'boxes/freebsd-amd64.box',
    'freebsd-i386'  => 'boxes/freebsd-i386.box',
    'openbsd-amd64' => 'boxes/openbsd-amd64.box',
    'openbsd-i386'  => 'boxes/openbsd-i386.box',
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
            apt-get -y install rsync ntpdate make wget gcc g++ chrpath perl pkg-config autoconf automake libtool nasm
          else
            yum -y install rsync ntpdate make wget gcc gcc-c++ chrpath perl pkg-config autoconf automake libtool nasm
          fi
        SH
      when /^freebsd/
        <<-SH
          set -ex
          pkg install -y rsync gmake wget gcc chrpath perl5 pkgconf autoconf automake libtool nasm
        SH
      when /^openbsd/
        <<-SH
          set -ex
          pkg_add -z rsync-- ntp gmake gtar-- wget g++-4.8.2p2 autoconf-2.69 automake-1.14.1 libtool nasm
          real_workdir_path=/home/vagrant/shared
          mkdir -p $real_workdir_path
          chown vagrant:vagrant $real_workdir_path
          ln -nfs $real_workdir_path /vagrant
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
