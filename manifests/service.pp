# Configures a daemontools service.
#
# A service, in daemontools parlance, consists of a directory
# (`/var/lib/service/$name`) which contains a few miscellaneous bits and
# pieces (which are of no interest to us here) and a script called `run`. 
# Pretty much all of the options on this type are about configuring this
# `run` script to do exactly what you want.  Daemontools (or, to be more
# precise, `supervise`(8)) will continuously re-run this script over and
# over again every time it stops.  Therefore you need to make sure that
# whatever command you want to run stays in the foreground and doesn't try
# to daemonise *itself* -- that's what daemontools is for.
#
# The only *required* attributes to this type are `command` and `user`, and,
# used by themselves, will do very little more than run `command` as `user. 
# The rest of the attributes are all about doing funky and fancy things.
#
# This type can ensure that the service is always present or permanently
# absent, running or stopped on every Puppet run (if you're into that kind
# of thing), and you can enable or disable the service from starting
# automatically.
#
# To trigger a restart of the service, simply notify the
# `Daemontools::Service` resource itself.
#
# The following parameters are available:
#
# * `namevar` (string)
#
#     The name of the service, as it will appear under
#     `/etc/service`.
#
# * `ensure` (string; optional; default: `"present"`)
#
#     The desired state of the service.  This can be one of "present" (the
#     service will be defined in `/etc/service`), "running" (Puppet will
#     attempt to start the service on every Puppet run if it is currently
#     not running), "stopped" (Puppet will attempt to stop the service on
#     every Puppet run if it is currently running), and "absent" (no trace
#     of the service will exist in `/etc/service`, `/var/lib/service`, or
#     the system process list).
#
# * `enable` (boolean or `undef`; optional; default: `undef`)
#
#     Whether the service should be started automatically at boot, or
#     restarted if it stops.  If set to `undef` (the default), Puppet will
#     make no stand on whether it should be up, down, or dancing a little
#     jig.  (See the `dance_a_jig` parameter for more info)
#
# * `command` (string; required)
#
#     The command that should be exec'd when starting the service. The
#     command should run in the foreground, and should catch signals and
#     cleanly terminate any child processes it spawns.  There are a
#     surprising number of programs that are incapable of following these
#     simple requirements.
#
# * `user` (string; required)
#
#     The user under which the service should execute.  Note that, by default,
#     the only group that the process will have is the user's primary group.
#     See the `use_secondary_groups` attribute if you'd like to give the process
#     all of the user's groups.
#
# * `sudo_control` (boolean / string; optional; default: `false`)
#
#     Create sudoers entries to allow the user to control the service.
#
#     If set to `true` or `"daemontools"`, entries for the standard daemontools
#     utilities (`svc`, `svok`, `svstat`) are configured.
#
#     If `"allah"`, entries for [Allah](https://github.com/anchor/allah) are
#     configured.
#
#     If you want to be able to sudo-control the service from either the standard
#     daemontools commands *or* Allah, then set this attribute to `"both"`.
#
# * `sudo_user` (string; optional; default: `$user`)
#
#     Ordinarily, `sudo_control` will grant the user specified by the `user`
#     attribute the ability to control the service.  However, if you want to
#     instead grant a *different* user that control (say, you run your
#     services as a dedicated, non-login-capable user, and you'd like to
#     allow a regular user to control the service), then specify that
#     username here.
#
# * `setuid` (boolean; optional; default: `true`)
#
#    Whether the user and group should be set before the command is
#    executed.  If set to false, the command itself is `exec`'d as `root`,
#    and the `UID` and `GID` environment variables are set to what the
#    service should be run as (and the program will need to do its own
#    privilege drop).  This option is designed for programs which need to
#    acquire privileged resources (like low-numbered TCP/UDP ports).
#
#    If none of the above makes any sense to you, *don't set this option*.
#
# * `use_secondary_groups` (boolean; optional; default: `false`)
#
#     Whether to run the process with the user's secondary groups. By default,
#     only the user's primary group is associated with the service, but some
#     configurations need secondary groups in order to work.
#
#     **NOTE**: This option will only work when 'setuid' is `true`.
#
# * `directory` (string; optional; default: `/var/lib/service/${name}`)
#
#     The working directory from which the command is executed. If omitted, the
#     service definition directory is used.
#
# * `log` (boolean / string; optional; default: `true`)
#
#     Whether logging should be enabled for the service. If enabled, stdout/stderr
#     of the service are redirected to a "log" subservice.
#     If this parameter is set to value which evaluates as true, but which isn't
#     the boolean `true`, the value is used as a custom command to execute for
#     the log service.  If set to `false`, no logging service is configured (and
#     your logs will be lost for all time).  If set to `true`, the default, the
#     logging command used will be
# 
#        multilog t s16777215 ./logs
#
#     Which, in case you don't speak multilog, means "prepend a timestamp, write
#     the logfiles to a subdirectory named `logs`, and rotate the logfile every
#     10MiB or so".  It's a good default.
#
# * `environment` (hash; optional; default: {})
#
#     Variables to set in the service command's environment.  This should be a
#     hash of `"NAME" => "some value"` pairs.
#
# * `allah_group` (string / array / `undef`; optional; default: `undef`)
#
#     Make this service part of a "group", which is used by
#     [Allah](https://github.com/anchor/allah) to stop/start multiple
#     services with a single command.  You can either specify a single
#     group, or a list of groups (either an array, or a string with each
#     group separated by whitespace).
#
# * `limit_data_segment`, `limit_stack_segment`, `limit_file_descriptors`,
#   `limit_processes`, `limit_file_size`, `limit_core_size`, `limit_rss`,
#   `limit_cpu_time`, `limit_virtual_memory`, `limit_locked_memory`
#   (integer / undef; optional; default: `undef`)
#
#     Various resource limits that may be applied to the service.  Any value
#     that is `undef` inherits the default limits set by the system.  Behind
#     the scenes, `ulimit`(8) is used to set the limits, and so the exact
#     operation of the limits are implementation-dependent.
#
# * `umask` (string / `undef`; optional; default: `undef`)
#
#     A umask to apply to the service.  If `undef`, the service program
#     inherits the system's default umask.
#
# * `pre_command` (string / `undef`; optional; default: `undef`)
#
#     A compound shell command (ie. you can provide multiple commands,
#     separated by semicolons) which is executed as `root` prior to the
#     service command itself being invoked.  This can be used to, for
#     example, create temporary directories or do custom system
#     configuration that the service needs to run.
#
# * `restart_flag` (string; optional; default: `"t"`)
#
#     Which flag to pass to the `svc` command to cause the service to
#     restart (as in `svc -<flag> /etc/service/$name`).  The default, `"t"`,
#     sends a `SIGTERM` to the service.  See `svc`(8) for the complete list
#     of possible flags `svc` will accept.  Personally, though, I'd
#     recommend fixing your program to cleanly terminate on `SIGTERM`,
#     myself...
#
# * `auto_restart` (boolean; optional; default: `true`)
#
#     Whether or not to automatically restart the service when the `run`
#     script changes.  In general it's considered good form to restart,
#     because that way the service is guaranteed to be running with the
#     correct configuration after Puppet has finished, but in certain select
#     circumstances you may wish to hold that off for a maintenance window.
#
define daemontools::service(
	$ensure                 = "present",
	$enable                 = true,
	$command,
	$user,
	$setuid                 = true,
	$use_secondary_groups   = false,
	$directory              = undef,
	$sudo_control           = false,
	$sudo_user              = undef,
	$log                    = true,
	$environment            = [],
	$allah_group            = undef,
	$restart_flag           = "t",
	$auto_restart           = true,
	$limit_data_segment     = undef,
	$limit_stack_segment    = undef,
	$limit_file_descriptors = undef,
	$limit_processes        = undef,
	$limit_file_size        = undef,
	$limit_core_size        = undef,
	$limit_rss              = undef,
	$limit_cpu_time         = undef,
	$limit_virtual_memory   = undef,
	$limit_locked_memory    = undef,
	$umask                  = undef,
	$pre_command            = undef
) {
	include daemontools::base

	if $name !~ /^\w[\w_.-]*(\/log)?$/ {
		fail("Invalid daemontools service name: ${name}")
	}

	##########################################################################
	# ENSURE
	#
	# The big cheese.  There are a tangled set of execs that get set in
	# amongst all these states; the most interesting one is on `"absent"`,
	# where (due to the need to stop any running services) we need to call
	# out to `purge_daemontools_service`.

	case $ensure {
		"present": { $service_ensure = "present" }
		"running": { $service_ensure = "running" }
		"stopped": { $service_ensure = "stopped" }
		"absent":  { $service_ensure = "absent"  }
		default:   { fail("Invalid value for ensure: ${ensure}") }
	}

	if $service_ensure == "present" or $service_ensure == "running" {
		# This exec is all about poking the service if it needs to be reloaded.
		# That gets signalled by notifying from other parts of the system
		exec { "daemontools/service/restart:${name}":
			command     => "/usr/bin/svc -${restart_flag} '/var/lib/service/${name}'",
			refreshonly => true,
			onlyif      => "/usr/bin/svstat '/var/lib/service/${name}' | /bin/grep -F '/var/lib/service/${name}: up '",
			require     => Noop["daemontools/running"],
			subscribe   => $auto_restart ? {
				true  => File["/var/lib/service/${name}/run"],
				false => undef,
			}
		}
	}
	
	if $service_ensure == "running" {
		exec { "daemontools/service/running:${name}":
			command   => "/usr/bin/svc -u '/var/lib/service/${name}'",
			onlyif    => "/usr/bin/svstat '/var/lib/service/${name}' | /bin/grep -F '/var/lib/service/${name}: down '",
			require   => Exec["daemontools/service/restart:${name}"];
		}
	}

	if $service_ensure == "stopped" {
		exec { "daemontools/service/stopped:${name}":
			command => "/usr/bin/svc -d '/var/lib/service/${name}'",
			onlyif  => "/usr/bin/svstat '/var/lib/service/${name}' | /bin/grep -F '/var/lib/service/${name}: up '",
			require => Noop["daemontools/running"];
		}
	}

	if $service_ensure == "absent" {
		exec { "daemontools/service/absent:${name}":
			command => "/usr/local/sbin/purge_daemontools_service '${name}'",
			onlyif  => "/usr/bin/test -e '/var/lib/service/${name}'"
		}
	} else {

		#######################################################################
		# ENABLE
		#
		# Thankfully, daemontools makes it relatively easy to signal that a
		# service should not be automagically started, simply by the presence
		# of a file.
		
		case $enable {
			true:    {
				file { "/var/lib/service/${name}/down":
					ensure => absent;
				}
			}
			false:   {
				file { "/var/lib/service/${name}/down":
					ensure => file;
				}
			}
			default: { fail("Invalid value for enable: ${enable}") }
		}
		
		#######################################################################
		# PERMISSIONS / OWNERSHIP
		#
		# Fairly straightforward logic here.

		# Only real usernames need apply.
		if $user =~ /^\w[\w_.-]*$/ {
			$daemontools_service_user = $user
		} else {
			fail("Invalid value for user: ${user}")
		}

		# How do we go about dropping privs?
		if $use_secondary_groups {
			if $setuid {
				$daemontools_service_uidgid = "su"
			} else {
				fail("Cannot use use_secondary_groups without setuid")
			}
		} else {
			if $setuid {
				$daemontools_service_uidgid = "setuidgid"
			} else {
				$daemontools_service_uidgid = "envuidgid"
			}
		}

		#######################################################################
		# NOOPS
		
		noop {
			"daemontools/service:${name}": ;
			"daemontools/configured:${name}":
				before => Noop["daemontools/configured"],
		}

		#######################################################################
		# WORKING DIRECTORY
		#
		# Trivial, but quite important to get right.

		if $directory {
			if $directory =~ /^[\/~]/ {
				$daemontools_service_directory = $directory
			} else {
				fail("directory must be an absolute path")
			}
		} else {
			$daemontools_service_directory = "/var/lib/service/${name}"
		}
		
		#######################################################################
		# SUDO
		#
		# Granting sudo privs.  /etc/service/make_me_a_sandwich optional.

		if $sudo_control {
			if $sudo_user {
				$sudo_user_ = $sudo_user
			} else {
				$sudo_user_ = $user
			}
			
			if $sudo_control == true
			   or $sudo_control == "daemontools"
			   or $sudo_control == "both" {
				daemontools::sudo { "${sudo_user_}/${name}":
					service => "/etc/service/${name}",
					user    => $sudo_user_,
					host    => "ALL",
					passwd  => false;
				}
			}
			
			if $sudo_control == "allah"
			   or $sudo_control == "both" {
				allah::sudo { "${sudo_user_}/${name}":
					service           => $name,
					user              => $sudo_user_,
					host              => "ALL",
					passwd            => false;
				}
			}
			
			if $sudo_control != true
			   and $sudo_control != "daemontools"
			   and $sudo_control != "allah"
			   and $sudo_control != "both" {
			   fail("Invalid value for sudo_control: ${sudo_control}")
			}
		}
		
		#######################################################################
		# ALLAH GROUPING

		if $allah_group {
			file { "/var/lib/service/${name}/group":
				content => join(maybe_split($allah_group, '[\s,]+'), " "),
				mode    => 0444;
			}
		}
		
		#######################################################################
		# LOGGING
		
		if $log {
			case $log {
				true:    { $log_cmd = "/usr/bin/multilog t s16777215 ./logs" }
				default: { $log_cmd = $log }
			}

			file { "/var/lib/service/${name}/log/logs":
				ensure  => directory,
				owner   => $user,
				mode    => 0750,
				require => Noop["daemontools/installed"];
			}

			daemontools::service { "${name}/log":
				ensure    => $ensure,
				command   => $log_cmd,
				directory => undef,
				user      => $user,
				log       => false;
			}

			noop {
				"daemontools/log-configured:${name}":
					require => Noop["daemontools/configured:${name}/log"],
					before  => Noop["daemontools/configured:${name}"];
				"daemontools/log-service:${name}":
					subscribe => Noop["daemontools/service:${name}"],
					notify    => Noop["daemontools/service:${name}/log"];
			}
		}
		
		#######################################################################
		# LIMITS
		#
		# Oh so many limits...

		if $limit_data_segment {
			if $limit_data_segment =~ /^\d+$/ {
				$ulimit_d = [ "-d ${limit_data_segment}" ]
			} else {
				fail("Invalid value for limit_data_segment: ${limit_data_segment}")
			}
		} else {
			$ulimit_d = []
		}

		if $limit_stack_segment {
			if $limit_stack_segment =~ /^\d+$/ {
				$ulimit_s = [ "-s ${limit_stack_segment}" ]
			} else {
				fail("Invalid value for limit_stack_segment: ${limit_stack_segment}")
			}
		} else {
			$ulimit_s = []
		}

		if $limit_file_descriptors {
			if $limit_file_descriptors =~ /^\d+$/ {
				$ulimit_n = [ "-n ${limit_file_descriptors}" ]
			} else {
				fail("Invalid value for limit_file_descriptors: ${limit_file_descriptors}")
			}
		} else {
			$ulimit_n = []
		}

		if $limit_processes {
			if $limit_processes =~ /^\d+$/ {
				$ulimit_u = [ "-u ${limit_processes}" ]
			} else {
				fail("Invalid value for limit_processes: ${limit_processes}")
			}
		} else {
			$ulimit_u = []
		}

		if $limit_file_size {
			if $limit_file_size =~ /^\d+$/ {
				$ulimit_f = [ "-f ${limit_file_size}" ]
			} else {
				fail("Invalid value for limit_file_size: ${limit_file_size}")
			}
		} else {
			$ulimit_f = []
		}

		if $limit_core_size {
			if $limit_core_size =~ /^(\d+|unlimited)$/ {
				$ulimit_c = [ "-c ${limit_core_size}" ]
			} else {
				fail("Invalid value for limit_core_size: ${limit_core_size}")
			}
		} else {
			$ulimit_c = []
		}

		if $limit_rss {
			if $limit_rss =~ /^\d+$/ {
				$ulimit_m = [ "-m ${limit_rss}" ]
			} else {
				fail("Invalid value for limit_rss: ${limit_rss}")
			}
		} else {
			$ulimit_m = []
		}

		if $limit_cpu_time {
			if $limit_cpu_time =~ /^\d+$/ {
				$ulimit_t = [ "-t ${limit_cpu_time}" ]
			} else {
				fail("Invalid value for limit_cpu_time: ${limit_cpu_time}")
			}
		} else {
			$ulimit_t = []
		}

		if $limit_virtual_memory {
			if $limit_virtual_memory =~ /^\d+$/ {
				$ulimit_v = [ "-v ${limit_virtual_memory}" ]
			} else {
				fail("Invalid value for limit_virtual_memory: ${limit_virtual_memory}")
			}
		} else {
			$ulimit_v = []
		}

		if $limit_locked_memory {
			if $limit_locked_memory =~ /^(\d+|unlimited)$/ {
				$ulimit_l = [ "-l ${limit_locked_memory}" ]
			} else {
				fail("Invalid value for limit_locked_memory: ${limit_locked_memory}")
			}
		} else {
			$ulimit_l = []
		}

		$daemontools_service_ulimits = womble_concat($ulimit_d, $ulimit_s, $ulimit_n, $ulimit_u, $ulimit_f, $ulimit_c, $ulimit_m, $ulimit_t, $ulimit_v, $ulimit_l)

		#######################################################################
		# INITIALIZATION COMMANDS

		if $pre_command {
			$daemontools_service_pre_commands = maybe_split($pre_command, '\n')
		} else {
			$daemontools_service_pre_commands = []
		}

		# Straightforward pass-through variables
		$daemontools_service_command     = $command
		$daemontools_service_environment = $environment
		$daemontools_service_umask       = $umask
		
		# What we've done all this work for
		file {
			[ "/var/lib/service/${name}", "/var/lib/service/${name}/supervise" ]:
				ensure  => directory,
				mode    => 0755,
				require => Noop["daemontools/installed"],
				before  => Noop["daemontools/configured:${name}"];
		}
		
		file { "/var/lib/service/${name}/run":
			content => template("daemontools/run"),
			mode    => 0555,
			require => Noop["daemontools/installed"],
			before  => Noop["daemontools/configured:${name}"];
		}

		# Aaaaaand go!
		if $name !~ /\/log$/ {
			file { "/etc/service/${name}":
				ensure  => "/var/lib/service/${name}",
				require => Noop["daemontools/configured:${name}"],
				before  => Noop["daemontools/configured"];
			}
		}
	}
}
