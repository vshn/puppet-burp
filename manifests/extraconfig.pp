# == Define burp::clientconfig
#
# Clientconfig on the BURP server.
#
# === Parameters
#
# [*client*]
#   Default: burp
#   Name of the BURP backup client which this extra config belongs to.
#
# [*configuration*]
#   Default: {}
#   Configuration hash.
#   See man page of BURP, section "CLIENT CONFIGURATION FILE OPTIONS",
#   for a list of possible values.
#
# === Authors
#
# Tobias Brunner <tobias.brunner@vshn.ch>
#
# === Copyright
#
# Copyright 2015 Tobias Brunner, VSHN AG
#
define burp::extraconfig (
  Hash    $configuration,
  String  $client = 'burp',
) {

  concat::fragment { "burpclient_extra_${name}":
    target  => "${burp::config_dir}/${client}-extra.conf",
    content => template('burp/burp-extra.conf.erb'),
    order   => 10,
  }

}
