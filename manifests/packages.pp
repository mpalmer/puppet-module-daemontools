class daemontools::packages {
	noop {
		"daemontools/installed": ;
	}

	package { daemontools:
		before => Noop["daemontools/installed"];
	}
}
