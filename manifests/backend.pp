# = Define haproxy::backend
#
#	 This define creates a fragment with backend definitions
#
# == Params
#
# [*be_name*]
#	backend's name. <name> will be used if it's not defined
#
# [*file_template*]
#	 if customized template should be used. Otherwise check backend-hostname-be_name
#
# [*options*]
#	 array of haproxy option to enable on this backend.
#
# [*mode*]
#	 haproxy mode directive. Can be http or tcp. Default http
#
define haproxy::backend (
	$backend_name	    = '',
	$file_template	    = 'haproxy/haproxy_backend_header.erb',
	$options		    = {
        'balance'   => 'roundrobin',
    },
	$mode			    = 'http',
    $servers            = {},
) 
{
	if ($mode != 'http') and ($mode != 'tcp') {
		fail ('mode paramater must be http or tcp')
	}

	$be_name = $backend_name ? {
		''		=> $name,
		default => $backend_name
	}

    concat { "/tmp/haproxy_backend_${be_name}.tmp" : }

    @@concat::fragment { "${be_name}_backend_header":
        content => template($file_template),
        tag     => "backendblock_${be_name}",
        target  => "/tmp/haproxy_backend_${be_name}.tmp",
        order   => '200',
    }

    $server_defaults = { 'backend' => "${be_name}" }
    create_resources('haproxy::backend::server', $servers, $server_defaults)

    Concat::Fragment <<| tag == "backendblock_${be_name}" |>>

    concat::fragment { "${be_name}_backend_block" :
        source  => "/tmp/haproxy_backend_${be_name}.tmp",
        target  => "${haproxy::config_dir}/haproxy.cfg",
        order   => '105',
    }

}


