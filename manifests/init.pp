# == Class: burp
#
# Full description of class burp here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
# === Examples
#
#  class { 'burp':
#    sample_parameter => 'sample value',
#  }
#
# === Authors
#
# Tobias Brunner
#
# === Copyright
#
# Copyright 2015 Tobias Brunner
#
class burp (
  # package installation handling
  $manage_package = true,
  $package_ensure = 'installed',
  $package_name = 'burp',
  # general burp configuration handling (client/server)
  $config_dir = '/etc/burp',
  # clients
  $clients = {},
) {

  ## Install BURP
  class { '::burp::install': } ->
  class { '::burp::config': }
  contain ::burp::install
  contain ::burp::config

  ## Instantiate Clients
  create_resources('::burp::client',$clients)

}
