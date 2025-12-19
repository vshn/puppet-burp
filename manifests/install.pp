# == Class burp::install
#
# This class installs the BURP package if `manage_package` is true.
#
# === Authors
#
# Tobias Brunner <tobias.brunner@vshn.ch>
#
# === Copyright
#
# Copyright 2015 Tobias Brunner, VSHN AG
#
class burp::install {

  if $burp::manage_package  {
    package { $burp::package_name:
      ensure => $burp::package_ensure,
    }
  }

}
