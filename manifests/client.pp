# == Define burp::client
#
#
#
define burp::client (
  $ca_dir = "/var/lib/burp/CA-client-${name}",
  $clientconf_tag = undef,
  $configuration = {},
  $cron_minute = '5',
  $cron_mode = 't',
  $manage_ca_dir = true,
  $manage_clientconfig = true,
  $manage_cron = true,
  $password = fqdn_rand_string(10),
  $server = "backup.${::fqdn}",
) {

  ## Default configuration parameters for BURP client
  # parameters coming from a default BURP installation (most of them)
  $_default_configuration = {
    'mode'                  => 'client',
    'port'                  => '4971',
    'server'                => $server,
    'password'              => $password,
    'cname'                 => $::fqdn,
    'pidfile'               => "/tmp/burp.client.${name}.pid",
    'syslog'                => 0,
    'stdout'                => 1,
    'progress_counter'      => 1,
    'server_can_restore'    => 0,
    'cross_filesystem'      => '/home',
    'cross_all_filesystems' => 0,
    'ca_burp_ca'            => '/usr/sbin/burp_ca',
    'ca_csr_dir'            => $ca_dir,
    'ssl_cert_ca'           => "${ca_dir}/ssl_cert_ca.pem",
    'ssl_cert'              => "${ca_dir}/ssl_cert-client.pem",
    'ssl_key'               => "${ca_dir}/ssl_cert-client.key",
    'ssl_peer_cn'           => $server,
  }
  $_configuration = merge($_default_configuration,$configuration)

  ## Write client configuration file
  file { "${::burp::config_dir}/burp-${name}.conf":
    ensure  => file,
    content => template('burp/burp.conf.erb'),
    require => Class['::burp::config'],
  }

  ## Prepare CA dir
  if $manage_ca_dir {
    file { $ca_dir:
      ensure => directory,
    }
  }

  ## Cronjob
  if $manage_cron {
    cron { "burp_client_${name}":
      command => "/usr/sbin/burp -c ${::burp::config_dir}/burp-${name}.conf -a ${cron_mode} >/dev/null 2>&1",
      user    => 'root',
      minute  => $cron_minute,
    }
  }

  ## Exported resource for clientconf
  if $manage_clientconfig {
    if $configuration['cname'] {
      $_clientname = $configuration['cname']
    } else {
      $_clientname = $::fqdn
    }
    if $clientconf_tag == undef {
      $_clientconf_tag = $server
    } else {
      $_clientconf_tag = $clientconf_tag
    }
    @@::burp::clientconfig { $_clientname:
      password => $password,
      tag      => $_clientconf_tag,
    }
  }

}
