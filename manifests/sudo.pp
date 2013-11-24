define daemontools::sudo(
	$service,
	$user,
	$host   = undef,
	$passwd = undef ) {

	$svc_bin    = "/usr/bin/svc"
	$svok_bin   = "/usr/bin/svok"
	$svstat_bin = "/usr/bin/svstat"

	if $service =~ /^\// {
		$daemontools_service_directory = $service
	} else {
		$daemontools_service_directory = "/var/lib/service/${service}"
	}

	Sudo::Entry {
		user   => $user,
		host   => $host,
		passwd => $passwd,
	}

	sudo::entry {
		"daemontools/sudo/${service}/${user}/svc/app": command => "${svc_bin} -[udopchaitk] ${daemontools_service_directory}";
		"daemontools/sudo/${service}/${user}/svc/log": command => "${svc_bin} -[udopchaitk] ${daemontools_service_directory}/log";

		"daemontools/sudo/${service}/${user}/svok/app": command => "${svok_bin} ${daemontools_service_directory}";
		"daemontools/sudo/${service}/${user}/svok/log": command => "${svok_bin} ${daemontools_service_directory}/log";

		"daemontools/sudo/${service}/${user}/svstat/app": command => "${svstat_bin} ${daemontools_service_directory}";
		"daemontools/sudo/${service}/${user}/svstat/log": command => "${svstat_bin} ${daemontools_service_directory}/log";
	}
}
