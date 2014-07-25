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
	$backend_name	= '',
	$file_template	= 'haproxy/haproxy_backend_header.erb',
	$options		= {
        'balance'   => 'roundrobin',
    },
	$mode			= 'http',
) {

	if ($mode != 'http') and ($mode != 'tcp') {
		fail ('mode paramater must be http or tcp')
	}

	$backend_name = $backend_name ? {
		''		=> $name,
		default => $backend_name
	}

	concat::fragment {"haproxy+002-${name}-001.tmp":
		content => template($file_template),
        target  => "${haproxy::config}/haproxy.cfg",
        order   => '201',
	}

}


