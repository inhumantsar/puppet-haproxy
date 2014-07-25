# = Define haproxy::listen
#
#	 This define creates a fragment with listen definition
#
# == Params
#
# [*listen_name*]
#	name of listen. <name> will be used it it's not specified
#
# [*bind*]
#	ip to bind
#
# [*port*]
#	port or port range to bind
#
# [*file_template*]
#	 if customized template should be used to override default template.
#
# [*mode*]
#	 haproxy mode directive. Can be http or tcp. Default tcp
#
# [*options*]
#	 array of options to use on this listen block
#
# [*monitor*]
#	 If true, it exports nrpe::check resource. Default: true. If monitor parame in haproxy class definition is false this parameter will be ignored
#
define haproxy::listen (
	$bind,
	$port,
	$listen_name		= '',
	$file_template		= 'haproxy/haproxy_listen_header.erb',
	$mode		        = 'tcp',
	$options			= '',
	$monitor			= true,
) {

	if ($mode != 'http') and ($mode != 'tcp') {
		fail ('mode paramater must be http or tcp')
	}

	$ls_name = $listen_name?{
		''			=> $name,
		default => $listen_name,
	}

	$array_options = is_array($options)? {
		true		=> $options,
		default => [ $options ],
	}

	if $bind !~ /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/ {
		fail('invalid ip_address value present in bind')
	}

	concat::fragment { "haproxy+004-listen-${name}" :
        target  => "${haproxy::config_dir}/haproxy.cfg",
		content => template($file_template),
        order   => '400',
	}

}
