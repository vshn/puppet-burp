#
class profile_burp::server (
  $configuration = {},
  $manage_firewall = true,
) {

  include ::burp

  $_my_configuration = {
    client_can_delete => 0,
    client_can_force_backup => 0,
    dedup_group => 'global',
    keep => [ '7','4' ],
    max_children => '20',
    restore_client => $::fqdn,
    ssl_compression => 'zlib0',
    status_address => '::',
    timer_arg =>  [
      '20h',
      'Mon,Tue,Wed,Thu,Fri,Sat,Sun,02,03,04,05,06,07',
    ],
  }
  $_configuration = merge($_my_configuration,$configuration)

  class { '::burp::server':
    configuration => $_configuration,
  }

  ## Firewall settings
  if $manage_firewall {
    firewall {
      '110 open BURP server and status port IPv4':
        dport  => [ 4971, 4972 ],
        proto  => 'tcp',
        action => 'accept';
      '110 open BURP server and status port IPv6':
        dport    => [ 4971, 4972 ],
        proto    => 'tcp',
        action   => 'accept',
        provider => 'ip6tables';
    }
  }

}
