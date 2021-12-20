# == Define burp::clientconfig
#
# Clientconfig on the BURP server.
#
# === Parameters
#
# [*clientname*]
#   Default:
#   Mandatory. Name of the BURP client.
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
  $clientname,
  $password,
  $configuration = {},
) {

  ## Input validation
  validate_string($clientname)
  validate_string($password)
  validate_hash($configuration)

  ## Default configuration parameters for BURP clientconfig
  $_default_configuration = {
    'password' => $password,
  }
  $_configuration = merge($_default_configuration,$configuration)

  ## Write client configuration file
  $params = {
    ensure  => file,
    content => template('burp/burp-clientconfig.conf.erb'),
    require => Class['::burp::config'],
    mode    => $::burp::server::config_file_mode,
    owner   => $::burp::server::user,
    group   => $::burp::server::group,
    replace => $::burp::server::config_file_replace,
  }
  ensure_resource('file',"${::burp::server::clientconfig_dir}/${clientname}",$params)

}
