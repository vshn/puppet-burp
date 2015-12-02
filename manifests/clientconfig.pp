# == Define burp::clientconfig
#
# Clientconfig on the BURP server.
#
# === Parameters
#
# [*password*]
#   Default:
#   Mandatory. Password for the BURP client to authenticate against
#   the BURP server.
#
# [*configuration*]
#   Default: {}
#   Configuration hash.
#   See man page of BURP, section "SERVER CLIENTCONFDIR FILE", for a list
#   of possible values.
#
# === Authors
#
# Tobias Brunner <tobias.brunner@vshn.ch>
#
# === Copyright
#
# Copyright 2015 Tobias Brunner, VSHN AG
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
