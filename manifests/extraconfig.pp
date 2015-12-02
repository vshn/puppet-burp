# == Define burp::clientconfig
#
#
#
define burp::extraconfig (
  $client,
  $configuration,
) {

  concat::fragment { "burpclient_extra_${name}":
    target  => "${::burp::config_dir}/${client}-extra.conf",
    content => template('burp/burp-extra.conf.erb'),
    order   => 10,
  }

}
