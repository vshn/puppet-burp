# == Class: burp
#
# This module installs and configures BURP backup server and client.
#
# === Parameters
#
# [*manage_package*]
#   Default: true
#   Enable or disable package installation.
#
# [*package_ensure*]
#   Default: installed
#   Can be used to choose exact package version to install.
#
# [*package_name*]
#   Default: burp
#   Name of the package.
#
# [*config_dir*]
#   Default: /etc/burp
#   Path where all the BURP configuration files will be written to.
#
# [*clients*]
#   Default: {}
#   Hash of `::burp::client` instances. Will be passed to `create_resources`.
#
# === Authors
#
# Tobias Brunner <tobias.brunner@vshn.ch>
#
# === Copyright
#
# Copyright 2015 Tobias Brunner, VSHN AG
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

  ## Input validation
  validate_bool($manage_package)
  validate_string($package_ensure)
  validate_string($package_name)
  validate_absolute_path($config_dir)
  validate_hash($clients)

  ## Install BURP
  class { '::burp::install': } ->
  class { '::burp::config': }
  contain ::burp::install
  contain ::burp::config

  ## Instantiate Clients
  create_resources('::burp::client',$clients)

}
