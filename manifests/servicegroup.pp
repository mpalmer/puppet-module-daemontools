# Configures a group of daemontools services as a unit.
#
# Useful if you need multiple worker processes that do much the same thing. 
# All the services configured will be placed in the same allah group.  The
# default group will be the resource's title, but you can specify a
# different group using the 'allah_group' parameter if you need to.
#
# The name of each service will be the title of the resource, with an
# underscore and the worker number appended to it.  Thus, this resource:
#
#     daemontools::servicegroup { "workit":
#        workers => 3,
#        ...
#     }
#
# will create daemontools services named `workit_0`, `workit_1`, and `workit_2`.
#
# To allow for cases where you want each worker to do something *slightly*
# different, the 'command' parameter is interpreted as ERB, with the worker
# number (starting from 0) available as the variable 'n'. So you can, for
# example, have a series of workers listening on a series of TCP ports:
# 
#     command => "/usr/sbin/exampled -l 127.0.0.1:<%= 1337 + n %>",
# 
# Most attributes for `daemontools::servicegroup` are identical to those for
# `daemontools::service`, with the exception of those documented below.
#
# * `command` (string; required)
#
#     This is very similar to the `command` attribute on `daemontools::service`, with the
#     exception that the command string is passed through ERB before being
#     written to the `run` file.  A single variable, `n`, is available to the
#     ERB interpreter, and it contains the number of the service, an integer
#     between `0` and `$workers - 1`.
#
# * `workers` (integer; required)
#     The number of worker processes to create. For each worker numbered
#     `$n={0..$workers-1}`, a daemontools service will be created called
#     `$name_$n` and have `n` available to the ERB processor for `command`,
#     as above.
#
define daemontools::servicegroup(
	$ensure                 = "present",
	$enable                 = true,
	$command,
	$user,
	$workers,
	$setuid                 = true,
	$use_secondary_groups   = false,
	$directory              = undef,
	$sudo_control           = false,
	$sudo_user              = undef,
	$log                    = true,
	$environment            = {},
	$allah_group            = $name,
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
	# There's something decidedly sick at work here... because we can't pass
	# in two lists of worker namevars and commands (varying by the worker
	# number), we're instead generating namevars to pass into
	# `daemontools::servicegroup::worker` which encode both the *actual*
	# service namevar as well as the command to be run.
	#
	# `d::s::worker` will then parse the namevar to determine the service
	# namevar and the command to run.
	$daemontools_servicegroup_workers = daemontools_servicegroup_mkworkernamevars($name, $command, $workers)

	daemontools::servicegroup::worker { $daemontools_servicegroup_workers:
		ensure                 => $ensure,
		enable                 => $enable,
		user                   => $user,
		setuid                 => $setuid,
		use_secondary_groups   => $use_secondary_groups,
		directory              => $directory,
		sudo_control           => $sudo_control,
		sudo_user              => $sudo_user,
		log                    => $log,
		environment            => $environment,
		allah_group            => $allah_group,
		restart_flag           => $restart_flag,
		limit_data_segment     => $limit_data_segment,
		limit_stack_segment    => $limit_stack_segment,
		limit_file_descriptors => $limit_file_descriptors,
		limit_processes        => $limit_processes,
		limit_file_size        => $limit_file_size,
		limit_core_size        => $limit_core_size,
		limit_rss              => $limit_rss,
		limit_cpu_time         => $limit_cpu_time,
		limit_virtual_memory   => $limit_virtual_memory,
		limit_locked_memory    => $limit_locked_memory,
		umask                  => $umask,
		pre_command            => $pre_command;
	}

	# Add sudo entry for whole allah group, if applicable
	if $sudo_control == "allah" or $sudo_control == "both" {
		allah::sudo { "${user}/${name}/${daemontools_servicegroup_allah_group}":
			service           => $allah_group,
			user              => $user,
			host              => "ALL",
			passwd            => false,
		}
	}
}
