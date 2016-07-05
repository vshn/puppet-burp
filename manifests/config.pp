# == Class burp::config
#
# This class is called from burp for service config.
#
class burp::config {

  file { $::burp::config_dir:
    ensure  => directory,
    mode    => '0750',
    purge   => true,
    recurse => true,
    force   => true,
  }

}
