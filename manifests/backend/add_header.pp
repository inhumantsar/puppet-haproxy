# = Define haproxy::backend::add_header
#
#	 add a header to request or response
#
# == Params
#
# [*header_name*]
#	 Name of the header to add. <name> will be used if it's not set.
#
# [*backend_name*]
#	 name of haproxy::backend resource to rely
#
# [*file_template*]
#	 if customized template should be used to override default template.
#
# [*type*]
#	 req|resp. Default: req
#
# [*value*]
#	 value of the header to add
#
# [*acl*]
#	 add "if <acl>" to the endof line. Only if specified acl is matched, header will be added
#
define haproxy::backend::add_header (
	$backend_name,
	$header_name	= '',
	$file_template  = 'haproxy/backend/add_header.erb',
	$type	        = 'req',
	$value	        = '',
	$acl	        = '',
) {

	if ($type != 'req') and ($type != 'resp') {
		fail('Type must be req|resp. Please specify correctly!')
	}

	$header = $header_name ? {
		''      => $name,
		default => $header_name,
	}

	$command = $type? {
		'req'   => 'reqadd',
		'resp'  => 'rspadd',
	}

	$header_value = $value? {
		''      => $value,
		default => ":\\ $value",
	}

    @@concat::fragment { "${backend_name}_add_header_${header}":
        content => template($file_template),
        tag     => "backendblock_${backend_name}",
        target  => "/tmp/haproxy_backend_${backend_name}.tmp",
        order   => '202',
    }

}
