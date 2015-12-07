#
class profile_burp::client (
  $server,
  $additional_includes = [],
  $cname = $::fqdn,
  $configuration = {},
  $dedup_group = 'global',
  $encryption_password = undef,
) {

  include ::burp

  validate_array($additional_includes)
  $_default_includes = [
    '/boot/grub',
    '/etc',
    '/home',
    '/usr/local',
    '/var/backups',
    '/var/lib/dpkg',
    '/var/log',
    '/var/spool',
  ]
  $_my_configuration = {
    backup_script => '/bin/run-parts',
    backup_script_pre_arg => ['--report', '--regex', '\'.*\'', '/usr/share/burp/pre-backup' ],
    backup_script_post_arg => ['--report', '--regex', '\'.*\'', '/usr/share/burp/post-backup' ],
    backup_script_reserved_args => 0,
    cname => $cname,
    dedup_group => $dedup_group,
    encryption_password => $encryption_password,
    include => union($_default_includes,$additional_includes),
    nobackup => '.nobackup',
    status_port => '4972',
  }

  # If the client is on the BURP server, we use the same certificate as already available
  if defined(Class['profile_burp::server']) {
    $_additional_configuration = {
      ssl_cert => '/var/lib/burp/ssl_cert-server.pem',
      ssl_cert_ca => '/var/lib/burp/ssl_cert_ca.pem',
      ssl_key => '/var/lib/burp/ssl_cert-server.key',
    }
    $_configuration1 = merge($_my_configuration,$_additional_configuration)
  } else {
    $_configuration1 = $_my_configuration
  }
  $_configuration = merge($_configuration1,$configuration)

  # the default client is named burp because this produces a
  # default configuration file for burp
  ::burp::client { 'burp':
    configuration => $_configuration,
    server        => $server,
  } ->

  ## Prepare pre-/postbackup scripts directories
  file { [ '/usr/share/burp/pre-backup', '/usr/share/burp/post-backup' ]:
    ensure => directory,
  }

}
