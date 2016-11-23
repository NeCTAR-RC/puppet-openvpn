#instantiate an instance of a vpn
class openvpn::client($server) inherits openvpn {

  openvpn::vpnclient {'default':
    o_remote => $server,
  }


  case $::lsbdistcodename {
    'xenial': {
      service {'openvpn@client':
        ensure => running,
      }
    }
    default: { }
  }
}
