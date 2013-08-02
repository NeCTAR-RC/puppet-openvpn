class openvpn::client($server) inherits openvpn {

  openvpn::vpnclient {'default':
    o_remote => $server,
  }

}
