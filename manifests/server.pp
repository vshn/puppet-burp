# == Class burp::server
#
#
#
class burp::server (
  $configuration = {},
  $manage_clientconfig = true,
) inherits burp {

  ## Default configuration parameters for BURP server
  # parameters coming from a default BURP installation (most of them)
  $_default_configuration = {
    'mode'                        => 'server',
    'port'                        => '4971',
    'status_port'                 => '4972',
    'directory'                   => $::burp::server_user_home,
    'clientconfdir'               => "${::burp::config_dir}/clients",
    'pidfile'                     => '/tmp/burp.server.pid',
    'hardlinked_archive'          => 0,
    'working_dir_recovery_method' => 'delete',
    'max_children'                => 5,
    'max_status_children'         => 5,
    'umask'                       => 0022,
    'syslog'                      => 1,
    'stdout'                      => 0,
    'client_can_delete'           => 1,
    'client_can_force_backup'     => 1,
    'client_can_list'             => 1,
    'client_can_restore'          => 1,
    'client_can_verify'           => 1,
    'version_warn'                => 1,
    'keep'                        => [7, 4, 6],
    'user'                        => $::burp::server_user,
    'group'                       => $::burp::server_group,
    'ca_conf'                     => $::burp::server_ca_config_file,
    'ca_name'                     => 'burpCA',
    'ca_server_name'              => $::fqdn,
    'ca_burp_ca'                  => '/usr/sbin/burp_ca',
    'ssl_cert_ca'                 => $::burp::server_ssl_cert_ca,
    'ssl_cert'                    => $::burp::server_ssl_cert,
    'ssl_key'                     => $::burp::server_ssl_key,
    'ssl_dhfile'                  => $::burp::server_ssl_dhfile,
    'timer_script'                => '/usr/local/bin/burp_timer_script',
    'timer_arg'                   => ['20h',
                                      'Mon,Tue,Wed,Thu,Fri,00,01,02,03,04,05,19,20,21,22,23',
                                      'Sat,Sun,00,01,02,03,04,05,06,07,08,17,18,19,20,21,22,23', ],
  }
  $_configuration = merge($_default_configuration,$configuration)

  ## Prepare system user
  if $::burp::manage_server_user {
    user { $::burp::server_user:
      ensure     => present,
      comment    => 'BURP server service user',
      home       => $::burp::server_user_home,
      managehome => false,
      shell      => '/usr/sbin/nologin',
      system     => true,
    }
  }

  ## Write server configuration file
  file { $::burp::server_config_file:
    ensure  => file,
    content => template('burp/burp.conf.erb'),
    owner   => $::burp::server_user,
    group   => $::burp::server_group,
    require => Class['::burp::config'],
  }

  ## Prepare CA
  if $::burp::server_ca_enabled {
    file { $::burp::server_ca_config_file:
      ensure  => file,
      content => template('burp/CA.cnf.erb'),
      owner   => $::burp::server_user,
      group   => $::burp::server_group,
      require => Class['::burp::config'],
    }
  }

  ## Prepare working directories
  file { $::burp::server_user_home:
    ensure => directory,
    owner  => $::burp::server_user,
    group  => $::burp::server_group,
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
    ::Burp::Clientconfig <<| tag == $::fqdn |>>
  }

  ## Manage service if enabled
  if $::burp::manage_server_service {
    File[$::burp::server_config_file] ~> Service['burp']
    if $::burp::manage_server_rsyslog {
      file { '/etc/rsyslog.d/21-burp.conf':
        ensure  => file,
        content => 'if $programname == \'burp\' then /var/log/burp.log',
        before  => Service['burp'],
      }
    }
    augeas { '/etc/default/burp':
      context => '/files/etc/default/burp',
      changes => 'set RUN yes',
    } ->
    service { 'burp':
      ensure => running,
      enable => true,
    }
  }

}
