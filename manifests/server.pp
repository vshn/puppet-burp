# == Class burp::server
#
#
#
class burp::server (
  $ca_config_file = '/etc/burp/CA.cnf',
  $ca_dir = '/var/lib/burp/CA',
  $ca_enabled = true,
  $clientconfig_dir = '/etc/burp/clients',
  $clientconfig_tag = $::fqdn,
  $config_file = '/etc/burp/server.conf',
  $configuration = {},
  $group = 'burp',
  $manage_clientconfig = true,
  $manage_rsyslog = true,
  $manage_service = true,
  $manage_user = true,
  $service_enable = true,
  $service_ensure = 'running',
  $service_name = $::burp::params::service_name,
  $ssl_cert = '/var/lib/burp/ssl_cert-server.pem',
  $ssl_cert_ca = '/var/lib/burp/ssl_cert_ca.pem',
  $ssl_dhfile = '/var/lib/burp/dhfile.pem',
  $ssl_key = '/var/lib/burp/ssl_cert-server.key',
  $user = 'burp',
  $user_home = '/var/lib/burp',
) inherits burp {

  ## Default configuration parameters for BURP server
  # parameters coming from a default BURP installation (most of them)
  $_default_configuration = {
    'ca_burp_ca'                  => '/usr/sbin/burp_ca',
    'ca_conf'                     => $ca_config_file,
    'ca_name'                     => 'burpCA',
    'ca_server_name'              => $::fqdn,
    'client_can_delete'           => 1,
    'client_can_force_backup'     => 1,
    'client_can_list'             => 1,
    'client_can_restore'          => 1,
    'client_can_verify'           => 1,
    'clientconfdir'               => $clientconfig_dir,
    'directory'                   => $user_home,
    'group'                       => $group,
    'hardlinked_archive'          => 0,
    'keep'                        => [7, 4, 6],
    'max_children'                => 5,
    'max_status_children'         => 5,
    'mode'                        => 'server',
    'pidfile'                     => '/tmp/burp.server.pid',
    'port'                        => '4971',
    'ssl_cert'                    => $ssl_cert,
    'ssl_cert_ca'                 => $ssl_cert_ca,
    'ssl_dhfile'                  => $ssl_dhfile,
    'ssl_key'                     => $ssl_key,
    'status_port'                 => '4972',
    'stdout'                      => 0,
    'syslog'                      => 1,
    'timer_arg'                   => ['20h',
                                      'Mon,Tue,Wed,Thu,Fri,00,01,02,03,04,05,19,20,21,22,23',
                                      'Sat,Sun,00,01,02,03,04,05,06,07,08,17,18,19,20,21,22,23', ],
    'timer_script'                => '/usr/local/bin/burp_timer_script',
    'umask'                       => '0022',
    'user'                        => $user,
    'version_warn'                => 1,
    'working_dir_recovery_method' => 'delete',
  }
  $_configuration = merge($_default_configuration,$configuration)

  ## Prepare system user
  if $manage_user {
    user { $user:
      ensure     => present,
      comment    => 'BURP server service user',
      home       => $user_home,
      managehome => false,
      shell      => '/usr/sbin/nologin',
      system     => true,
    }
  }

  ## Write server configuration file
  file { $config_file:
    ensure  => file,
    content => template('burp/burp.conf.erb'),
    owner   => $user,
    group   => $group,
    require => Class['::burp::config'],
  }

  ## Prepare CA
  if $ca_enabled {
    file { $ca_config_file:
      ensure  => file,
      content => template('burp/CA.cnf.erb'),
      owner   => $user,
      group   => $group,
      require => Class['::burp::config'],
    }
  }

  ## Prepare working directories
  file { $user_home:
    ensure => directory,
    owner  => $user,
    group  => $group,
  } ->
  file { $clientconfig_dir:
    ensure  => directory,
    purge   => true,
    recurse => true,
  }

  ## Deliver original scripts
  file { '/usr/local/bin/burp_timer_script':
    ensure => file,
    source => 'puppet:///modules/burp/timer_script',
  }
  file { '/usr/local/bin/burp_summary_script':
    ensure => file,
    source => 'puppet:///modules/burp/summary_script',
  }
  file { '/usr/local/bin/burp_notify_script':
    ensure => file,
    source => 'puppet:///modules/burp/notify_script',
  }
  file { '/usr/local/bin/burp_ssl_extra_checks_script':
    ensure => file,
    source => 'puppet:///modules/burp/ssl_extra_checks_script',
  }

  ## Instantiate clientconfigs
  if $manage_clientconfig {
    ::Burp::Clientconfig <<| tag == $clientconfig_tag |>>
  }

  ## Manage service if enabled
  if $manage_service {
    File[$config_file] ~> Service['burp']
    if $manage_rsyslog {
      file { '/etc/rsyslog.d/21-burp.conf':
        ensure  => file,
        content => 'if $programname == \'burp\' then /var/log/burp.log',
        before  => Service['burp'],
      }
    }
    augeas { '/etc/default/burp':
      context => '/files/etc/default/burp',
      changes => [
        'set RUN yes',
        "set DAEMON_ARGS '\"-c ${config_file}\"'",
      ],
    } ->
    service { 'burp':
      ensure => running,
      enable => true,
    }
  }

}
