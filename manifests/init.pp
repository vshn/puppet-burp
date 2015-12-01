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
  $package_ensure = 'installed',
  $package_name = $::burp::params::package_name,
  $manage_package = true,
  # general burp configuration handling
  $config_dir = '/etc/burp',
  # burp server configuration
  $manage_server_service = true,
  $manage_server_user = true,
  $server_config_file = '/etc/burp/burp-server.conf',
  $server_config_clientconfdir = '/etc/burp/clients',
  $server_group = 'burp',
  $server_service_enable = true,
  $server_service_ensure = 'running',
  $server_service_name = $::burp::params::service_name,
  $server_user = 'burp',
  $server_user_home = '/var/lib/burp',
  $server_ca_config_file = '/etc/burp/CA.cnf',
  $server_ca_dir = '/var/lib/burp/CA',
  $server_ca_enabled = true,
  $server_ssl_cert_ca = '/var/lib/burp/ssl_cert_ca.pem',
  $server_ssl_cert = '/var/lib/burp/ssl_cert-server.pem',
  $server_ssl_key = '/var/lib/burp/ssl_cert-server.key',
  $server_ssl_dhfile = '/var/lib/burp/dhfile.pem',
  # clients
  $clients = {},
) inherits ::burp::params {

  ## Install BURP
  class { '::burp::install': } ->
  class { '::burp::config': }
  contain ::burp::install
  contain ::burp::config

  ## Instantiate Clients
  create_resources('::burp::client',$clients)

}
