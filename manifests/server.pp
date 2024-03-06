# == Class burp::server
#
# This class configures the BURP backup server.
#
# === Parameters
#
# [*ca_config_file*]
#   Default: /etc/burp/CA.cnf
#   CA configuration file.
#
# [*ca_dir*]
#   Default: /var/lib/burp/CA
#   Directory where all CA related files are saved to.
#
# [*ca_enabled*]
#   Default: true
#   Whether to enable the BURP CA or not.
#
# [*clientconfig_dir*]
#   Default: /etc/burp/clients
#   Directory to save client configuration to.
#
# [*clientconfig_tag*]
#   Default: $::fqdn
#   Puppet tag to collect exported `burp::clientconfig` resources.
#
# [*clientconfigs*]
#   Default: {}
#   Hash of `::burp::clientconfig` instances. Will be passed to `create_resources`.
#
# [*config_file*]
#   Default: /etc/burp/burp-server.conf
#   Configuration file to put BURP backup server configuration into.
#
# [*configuration*]
#   Default: {}
#   Hash of server configuration directives. See man page of BURP, section
#   "SERVER CONFIGURATION FILE OPTIONS", for a detailed list of all possible
#   values. A big bunch of default values are already prepared (see code below).
#   Values defined in this hash will get merged and will override the default
#   parameters!
#
# [*group*]
#   Default: burp
#   Group to run BURP backup server under.
#
# [*user*]
#   Default: burp
#   User to run BURP backup server under.
#
# [*config_file_mode*]
#   Default: 0600
#   Mode of burp config dirs and files
#
# [*homedir_file_mode*]
#   Default: 0750
#   Mode of burp data dirs and files
#
# [*manage_clientconfig*]
#   Default: true
#   Collect `::burp::clientconfig` exported resources, filtered by `clientconfig_tag`.
#
# [*manage_logrotate*]
#   Default: true
#   Rotate /var/log/burp/burp.log daily. Only active if manage_rsyslog is true as well.
#   Requires puppet/logrotate module.
#
# [*manage_rsyslog*]
#   Default: true
#   Put a rsyslog config file under /etc/rsyslog.d/21-burp.conf to filter syslog
#   messages from BURP backup server and put them into /var/log/burp/burp.log.
#
# [*manage_service*]
#   Default: true
#   Manage the BURP backup system service.
#
# [*manage_user*]
#   Default: true
#   Manage the BURP backup system service user.
#
# [*service_enable*]
#   Default: true
#   Enable the BURP backup system service on system boot.
#
# [*service_ensure*]
#   Default: running
#   Desired state of the BURP backup system service.
#
# [*service_name*]
#   Default: burp
#   Name of the BURP backup system service.
#
# [*ssl_cert*]
#   Default: /var/lib/burp/ssl_cert-server.pem
#   BURP backup server SSL certificate file.
#
# [*ssl_cert_ca*]
#   Default: /var/lib/burp/ssl_cert_ca.pem
#   BURP backup server SSL CA certificate file.
#
# [*ssl_dhfile*]
#   Default: /var/lib/burp/dhfile.pem
#   BURP backup server SSL DH params file.
#
# [*ssl_key*]
#   Default: /var/lib/burp/ssl_cert-server.key
#   BURP backup server SSL certificate key file.
#
# [*user_home*]
#   Default: /var/lib/burp
#   BURP backup server home and working directory.
#
# [*config_file_replace*]
#   Default: true
#   Boolean stating whether to overwrite local changes to config files.
#
# [*scripts_replace*]
#   Default: true
#   Boolean stating whether to overwrite local changes to scripts.
#
# === Authors
#
# Tobias Brunner <tobias.brunner@vshn.ch>
#
# === Copyright
#
# Copyright 2015 Tobias Brunner, VSHN AG
#
class burp::server (
  $ca_config_file = '/etc/burp/CA.cnf',
  $ca_dir = '/var/lib/burp/CA',
  $ca_enabled = true,
  $clientconfig_dir = '/etc/burp/clients',
  $clientconfig_tag = $::fqdn,
  $clientconfigs = {},
  $config_file = '/etc/burp/burp-server.conf',
  $configuration = {},
  $user = 'burp',
  $group = 'burp',
  $config_file_mode = '0600',
  $homedir_file_mode = '0750',
  $manage_clientconfig = true,
  $manage_logrotate = true,
  $manage_rsyslog = true,
  $manage_service = true,
  $manage_user = true,
  $service_enable = true,
  $service_ensure = 'running',
  $service_name = 'burp',
  $ssl_cert = '/var/lib/burp/ssl_cert-server.pem',
  $ssl_cert_ca = '/var/lib/burp/ssl_cert_ca.pem',
  $ssl_dhfile = '/var/lib/burp/dhfile.pem',
  $ssl_key = '/var/lib/burp/ssl_cert-server.key',
  $user_home = '/var/lib/burp',
  $config_file_replace = true,
  $scripts_replace = true,
) {

  ## Input validation
  validate_absolute_path($ca_config_file)
  validate_absolute_path($ca_dir)
  validate_bool($ca_enabled)
  validate_absolute_path($clientconfig_dir)
  validate_string($clientconfig_tag)
  validate_absolute_path($config_file)
  validate_hash($configuration)
  validate_string($group)
  validate_bool($manage_clientconfig)
  validate_bool($manage_rsyslog)
  validate_bool($manage_service)
  validate_bool($manage_user)
  validate_bool($service_enable)
  validate_string($service_ensure)
  validate_string($service_name)
  validate_absolute_path($ssl_cert)
  validate_absolute_path($ssl_cert_ca)
  validate_absolute_path($ssl_dhfile)
  validate_absolute_path($ssl_key)
  validate_string($user)
  validate_absolute_path($user_home)
  validate_bool($config_file_replace)
  validate_bool($scripts_replace)

  include ::burp

  # OS specifics
  case downcase($::osfamily) {
    'debian': {
      $_syslog_owner = 'syslog'
      $_nologin = '/usr/sbin/nologin'
    }
    'redhat': {
      $_syslog_owner = 'adm'
      $_nologin = '/sbin/nologin'
    }
  }

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
      shell      => $_nologin,
      system     => true,
    }
  }

  ## Write server configuration file
  file { $config_file:
    ensure  => file,
    content => template('burp/burp.conf.erb'),
    mode    => $config_file_mode,
    owner   => $user,
    group   => $group,
    require => Class['::burp::config'],
    replace => $config_file_replace,
  }

  ## Prepare CA
  if $ca_enabled {
    file { $ca_config_file:
      ensure  => file,
      content => template('burp/CA.cnf.erb'),
      mode    => $config_file_mode,
      owner   => $user,
      group   => $group,
      require => Class['::burp::config'],
      replace => $config_file_replace,
    }
  }

  ## Prepare working directories
  file { $user_home:
    ensure => directory,
    mode   => $homedir_file_mode,
    owner  => $user,
    group  => $group,
  } ->
  file { $clientconfig_dir:
    ensure  => directory,
    mode    => $config_file_mode,
    purge   => $config_file_replace,
    recurse => $config_file_replace,
    owner   => $user,
    group   => $group,
  }

  ## Deliver original scripts
  file { '/usr/local/bin/burp_timer_script':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/burp/timer_script',
    replace => $scripts_replace,
  }
  file { '/usr/local/bin/burp_summary_script':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/burp/summary_script',
    replace => $scripts_replace,
  }
  file { '/usr/local/bin/burp_notify_script':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/burp/notify_script',
    replace => $scripts_replace,
  }
  file { '/usr/local/bin/burp_ssl_extra_checks_script':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/burp/ssl_extra_checks_script',
    replace => $scripts_replace,
  }

  ## Instantiate clientconfigs
  if $manage_clientconfig {
    ::Burp::Clientconfig <<| tag == $clientconfig_tag |>>
    create_resources('::burp::clientconfig',$clientconfigs)
  }

  ## Manage service if enabled
  if $manage_service {
    File[$config_file] ~> Service['burp']
    if $manage_rsyslog {
      file { '/var/log/burp':
        ensure => directory,
        mode   => '0700',
        owner  => $_syslog_owner,
        group  => 'adm',
      }
      # Pitfall: This file resource does not notify rsyslog and so it only comes active
      # after manually reloading rsyslog
      file { '/etc/rsyslog.d/21-burp.conf':
        ensure  => file,
        content => 'if $programname == \'burp\' then /var/log/burp/burp.log',
        before  => Service['burp'],
      }
      # Define Logrotate
      if $manage_logrotate {
        logrotate::rule { 'burp':
          path         => '/var/log/burp/burp.log',
          copytruncate => true,
          missingok    => true,
          rotate_every => 'day',
          rotate       => '31', # must be a string to be recognised as an integer...
          compress     => true,
          ifempty      => true,
          postrotate   => 'reload rsyslog /dev/null 2>&1 || true',
        }
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
      name   => $service_name,
      enable => true,
    }
  }

}
