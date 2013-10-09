class openvpn {

  package { 'openvpn':
    ensure => installed;
  }

  file { "/var/log/openvpn":
    ensure => directory,
  }

  include logrotate

  file { "/etc/logrotate.d/openvpn.conf":
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0640',
    source => 'puppet:///modules/openvpn/logrotate.conf',
  }

  service { 'openvpn':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['openvpn'],
  }

  define vpnclient($o_remote, $o_port='1194', $o_proto='tcp', $o_dev='tun') {

    include openvpn

    if (is_ip_address($o_remote) and has_interface_with("ipaddress", $o_remote)) or $::fqdn == $o_remote {
      $is_remote = true
    }

    if $is_remote != true {

      if $name == 'default' {
        $path = "/etc/openvpn/client.conf"
      } else {
        $path = "/etc/openvpn/${name}-client.conf"
      }

      file { "${name}-client-conf":
        path    => $path,
        owner   => root,
        group   => root,
        mode    => 0644,
        require => Package['openvpn'],
        notify  => Service['openvpn'],
        content => template('openvpn/client.conf.erb'),
      }
    }
  }

  define vpnserver($o_network='10.10.0.0', $o_netmask='255.255.255.0', $o_port='1194', $o_proto='tcp', $o_dev='tun', $o_management='5555', $o_routes=undef) {

    include openvpn

    if $o_routes == undef {
      $openvpn_routes = ["${o_network} ${o_netmask}"]
    } else {
      $openvpn_routes = $o_routes
    }

    exec { "${name}-create-dh2048.pem":
      path    => '/bin:/usr/bin',
      command => 'openssl dhparam -out /etc/openvpn/dh2048.pem 2048 1>/dev/null 2>&1',
      timeout => 180,
      unless  => 'test -f /etc/openvpn/dh2048.pem',
      require => Package['openvpn'],
      notify  => Service['openvpn'],
    }

    file { "${name}-server-conf":
      path    => "/etc/openvpn/${name}-server.conf",
      owner   => root,
      group   => root,
      mode    => 0644,
      require => Package['openvpn'],
      notify  => Service['openvpn'],
      content => template('openvpn/server.conf.erb'),
    }

    $infra_hosts = hiera('firewall::infra_hosts', [])
    firewall::multisource {[ prefix($infra_hosts, '200 openvpn,') ]:
      action => 'accept',
      proto  => $o_proto,
      dport  => $o_port,
    }
  }
}
