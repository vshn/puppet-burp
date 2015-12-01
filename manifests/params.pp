# == Class burp::params
#
# This class is meant to be called from burp.
# It sets variables according to platform.
#
class burp::params {

  case $::osfamily {
    'Debian': {
      $package_name = 'burp'
      $service_name = 'burp'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

}
