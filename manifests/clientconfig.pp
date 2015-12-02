# == Define burp::clientconfig
#
#
#
define burp::clientconfig (
  $password,
  $configuration = {},
) {

  ## Default configuration parameters for BURP clientconfig
  $_default_configuration = {
    'password' => $password,
  }
  $_configuration = merge($_default_configuration,$configuration)

  ## Write client configuration file
  file { "${::burp::server::clientconfig_dir}/${name}":
    ensure  => file,
    content => template('burp/burp-clientconfig.conf.erb'),
    require => Class['::burp::config'],
  }

}
