# Sets up a single `daemontools::service` as part of a servicegroup.
#
# This type is not intended for use directly by end-user manifests.
# Do not use this type directly, its API and behaviour are subject to
# change without notice.
#
define daemontools::servicegroup::worker(
	$ensure                 = "present",
	$enable                 = true,
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
	$worker_name = regsubst($name, "^([^/]+)/(.*)$", '\1')
	$command = regsubst($name, "^([^/]+)/(.*)$", '\2')

	daemontools::service { $worker_name:
		ensure                 => $ensure,
		enable                 => $enable,
		command                => $command,
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
}
