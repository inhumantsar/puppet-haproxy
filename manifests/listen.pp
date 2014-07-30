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

    concat { "/tmp/haproxy_listen_${ls_name}.tmp" : }

    @@concat::fragment { "${ls_name}_listen_header":
        content => template($file_template),
        tag     => "listenblock_${ls_name}",
        target  => "/tmp/haproxy_listen_${ls_name}.tmp",
        order   => '300',
    }

    Concat::Fragment <<| tag == "listenblock_${ls_name}" |>>

    concat::fragment { "${ls_name}_listen_block" :
        source  => "/tmp/haproxy_listen_${ls_name}.tmp",
        target  => "${haproxy::config_dir}/haproxy.cfg",
        order   => '104',
    }


}
