# == Class burp::install
#
# This class is called from burp for install.
#
class burp::install {

  if $::burp::manage_package  {
    package { $::burp::package_name:
      ensure => $::burp::package_ensure,
    }
  }

}
