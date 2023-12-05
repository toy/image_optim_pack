# frozen_string_literal: true

Veewee::Session.declare({
  cpu_count: '1',
  memory_size: '512',
  disk_size: '8192',
  disk_format: 'VDI',
  hostiocache: 'off',
  os_type_id: 'RedHat6_64',
  iso_file: 'CentOS-7-x86_64-Minimal-2009.iso',
  iso_src: 'http://linux.darkpenguin.net/distros/CentOS/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso',
  iso_sha256: '07b94e6b1a0b0260b94c83d6bb76b26bf7a310dc78d7a9c7432809fb9bc6194a',
  iso_download_timeout: '1000',
  boot_wait: '10',
  boot_cmd_sequence: [
    '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>',
  ],
  kickstart_port: '7122',
  kickstart_timeout: '300',
  kickstart_file: 'ks.cfg',
  ssh_login_timeout: '10000',
  ssh_user: 'veewee',
  ssh_password: 'veewee',
  ssh_key: '',
  ssh_host_port: '7222',
  ssh_guest_port: '22',
  sudo_cmd: "echo '%p'|sudo -S sh '%f'",
  shutdown_cmd: '/sbin/halt -h -p',
  postinstall_files: %w[../centos-postinstall.sh],
  postinstall_timeout: '10000',
  skip_iso_transfer: true,
})
