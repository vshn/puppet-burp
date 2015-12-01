# == Class burp::config
#
# This class is called from burp for service config.
#
class burp::config {

  file { $::burp::config_dir:
    ensure  => directory,
    purge   => true,
    recurse => true,
  } ->
  file { $::burp::server_config_clientconfdir:
    ensure  => directory,
    purge   => true,
    recurse => true,
  }

}
