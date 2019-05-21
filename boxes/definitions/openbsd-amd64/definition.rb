# frozen_string_literal: true

Veewee::Session.declare({
  :cpu_count => '1',
  :memory_size => '512',
  :disk_size => '8192',
  :disk_format => 'VDI',
  :hostiocache => 'off',
  :os_type_id => 'OpenBSD_64',
  :iso_file => 'OpenBSD-5.9-amd64.iso',
  :iso_src => 'https://www.mirrorservice.org/pub/OpenBSD/5.9/amd64/install59.iso',
  :iso_sha256 => '685262fc665425c61a2952b2820389a2d331ac5558217080e6d564d2ce88eecb',
  :iso_download_timeout => '1000',
  :boot_wait => '50',
  :boot_cmd_sequence => [
    'I<Enter>',             # I - install
    'us<Enter>',            # set the keyboard
    'OpenBSD59-x64<Enter>', # set the hostname
    '<Enter>',              # Which nic to config ? [em0]
    '<Enter>',              # do you want dhcp ? [dhcp]
    '<Wait>' * 5,
    '<Enter>',              # IPV6 for em0 ? [none]
    '<Enter>',              # Which other nic do you wish to configure [done]
    'vagrant<Enter>',       # Pw for root account
    'vagrant<Enter>',
    'yes<Enter>',           # Start sshd by default ? [yes]
    'no<Enter>',            # Do you want the X window system [yes]
    'vagrant<Enter>',       # Setup a user ?
    'vagrant<Enter>',       # Full username
    'vagrant<Enter>',       # Pw for this user
    'vagrant<Enter>',
    'yes<Enter>',           # Do you want to allow sshd for root ? [no]
    'GB<Enter>',            # What timezone are you in ?
    '<Enter>',              # Available disks [sd0]
    'W<Enter>',             # Use (W)whole disk or (E)edit MBR ? [whole]
    'A<Enter>',             # Use (A)auto layout ... ? [a]
    '<Wait>' * 5,
    '<Enter>',              # location of the sets [cd0]
    '<Enter>',              # Pathname to sets ? [5.9/amd64]
    '-game59.tgz<Enter>',   # Remove games and X
    '-xbase59.tgz<Enter>',
    '-xshare59.tgz<Enter>',
    '-xfont59.tgz<Enter>',
    '-xserv59.tgz<Enter>',
    'done<Enter>',
    '<Wait>',
    'yes<Enter>',           # CD does not contain SHA256.sig (5.9) Continue without verification?
    '<Wait>' * 60,
    'done<Enter>',          # Location of sets?
    'yes<Enter><Wait>',     # Time appears wrong. Set to ...? [yes]
    '<Wait>' * 6,
    'reboot<Enter>',
    '<Wait>' * 6,
  ],
  :kickstart_port => '7122',
  :kickstart_timeout => '300',
  :kickstart_file => '',
  :ssh_login_timeout => '10000',
  :ssh_user => 'root',
  :ssh_password => 'vagrant',
  :ssh_key => '',
  :ssh_host_port => '7222',
  :ssh_guest_port => '22',
  :sudo_cmd => "sh '%f'",
  :shutdown_cmd => '/sbin/halt -p',
  :postinstall_files => %w[../openbsd-postinstall.sh],
  :postinstall_timeout => '10000',
  :skip_iso_transfer => true,
})
