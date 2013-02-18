class openvpn {
	package {
		[ openvpn ] : ensure => latest;
	}
}

class openvpn::client inherits openvpn {
	
	file {
		client-conf:
			path => "/etc/openvpn/client.conf",
			owner => root,
			group => root,
			backup => false,
			mode => 644,
			require => Package["openvpn"],
			content => template("openvpn/client.conf.erb");
	}

	service {
		openvpn:
			ensure => running,
			enable => true,
			hasrestart => true,
			hasstatus => true,
			status => "true",
			require => Package["openvpn"],
			subscribe => [ File[client-conf],Package["openvpn"]]
	}
}

class openvpn::server inherits openvpn {
  file { "/var/log/openvpn":
    ensure => directory,
  }


# these two need to be passed different options
# not sure the best way to make this happen.
	file {
		server-conf:
			path => "/etc/openvpn/server.conf",
			owner => root,
			group => root,
			backup => false,
			mode => 644,
			require => Package["openvpn"],
			content => template("openvpn/server.conf.erb");
	}

	file {
		monitor-conf:
			path => "/etc/openvpn/monitor.conf",
			owner => root,
			group => root,
			backup => false,
			mode => 644,
			require => Package["openvpn"],
			content => template("openvpn/server.conf.erb");
	}

}
