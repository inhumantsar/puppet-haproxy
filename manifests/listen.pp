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
	$listen_name		= '',
	$file_template		= 'haproxy/haproxy_listen_header.erb',
	$mode		        = '',
	$options			= {},
) {

	$ls_name = $listen_name ? {
		''		=> $name,
		default => $listen_name,
	}

    $array_bind = is_array($bind) ? {
        true    => $bind,
        default => [ $bind ],
    }

    concat { "/tmp/haproxy_listen_${ls_name}.tmp" : }

    @@concat::fragment { "${ls_name}_listen_header":
        content => template($file_template),
        tag     => "listenblock_${ls_name}",
        target  => "/tmp/haproxy_listen_${ls_name}.tmp",
        order   => '100',
    }

    Concat::Fragment <<| tag == "listenblock_${name}" |>>

    concat::fragment { "${ls_name}_listen_block" :
        source  => "/tmp/haproxy_listen_${ls_name}.tmp",
        target  => "${haproxy::config_dir}/haproxy.cfg",
        order   => '101',
        require => [ Concat["/tmp/haproxy_listen_${ls_name}.tmp"], Concat::Fragment["${ls_name}_listen_header"] ],
    }


}
