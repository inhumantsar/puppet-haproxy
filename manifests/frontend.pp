# = Define haproxy::frontend
#
#	 This define creates a fragment with backend definitions
#
# == Params
#
# [*frontend_name*]
#	 frontend name. <name> will be used if it's not defined
#
# [*bind*]
#	 String or Array of IPs and ports to listen on eg: [ '*:4747', '10.0.2.5:80', 'host.name.domain:90' ]
#
# [*file_template*]
#	 if customized template should be used.
#
# [*defaul_backend*]
#	 default backend to use
#
# [*mode*]
#	 haproxy mode directive. Can be http or tcp. Default tcp
#
# [*options*]
#	 hash of options
#
define haproxy::frontend (
	$bind,
	$default_backend,
	$frontend_name		= '',
	$file_template		= 'haproxy/haproxy_frontend_header.erb',
	$mode				= 'http',
	$options			= {},
) {

	if ($mode != 'http') and ($mode != 'tcp') {
		fail ('mode paramater must be http or tcp')
	}

	$fe_name = $frontend_name ? {
		''		=> $name,
		default => $frontend_name,
	}

	$array_bind = is_array($bind) ? {
		true	=> $bind,
		default => [ $bind ],
	}

	concat::fragment {"haproxy+003-${name}-001.tmp":
		content => template($file_template),
        target  => "${haproxy::config_dir}/haproxy.cfg",
        order   => '301',
	}

}
