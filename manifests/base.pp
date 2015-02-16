class daemontools::base {
	include daemontools::packages

	noop {
		"daemontools/configured": require => Noop["daemontools/installed"];
		"daemontools/running":    require => Noop["daemontools/configured"];
	}

	file {
		[
			"/etc/service",
			"/var/lib/service",
		]:
			ensure  => directory,
			mode    => 0751,
			require => Package["daemontools"],
			before  => Noop["daemontools/installed"];
		"/usr/local/sbin/purge_daemontools_service":
			source  => "puppet:///modules/daemontools/usr/local/sbin/purge_daemontools_service",
			mode    => 0555,
			owner   => "root",
			group   => "root";
	}

	libwomble::initscript { "daemontools":
		source => "puppet:///modules/daemontools/etc/rc.d/init.d/daemontools",
		before => Noop["daemontools/configured"];
	}

	service { daemontools:
		ensure     => running,
		enable     => true,
		hasstatus  => true,
		hasrestart => true,
		require    => Noop["daemontools/configured"],
		before     => Noop["daemontools/running"];
	}
}
