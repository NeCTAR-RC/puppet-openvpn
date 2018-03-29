# OpenVPN params class
class openvpn::params {

  # check if client is running puppet 3
  $puppet3 = (versioncmp($::puppetversion,'4.0.0') < 0)

  if $puppet3 {
    $ssldir = '/var/lib/puppet/ssl'
  }
  else {
    $ssldir = '/etc/puppetlabs/puppet/ssl'
  }

}
