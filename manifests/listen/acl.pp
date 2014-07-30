# = Define haproxy::listen::acl
#
# This define add an haproxy acl on listen section
#
# == Parameters
#
# [*listen_name*]
#	 name of haproxy::listen resource to rely
#
# [*acl_name*]
#	 acl name. If not specified <name> will be used
#
# [*condition*]
#	 condition that must be satisfied to match acl
#
# [*use_backend*]
#	 backend to use if acl if matched
#
# [*file_template*]
#	 if customized template should be used to override default template.
#
define haproxy::listen::acl (
	$listen_name,
	$condition,
	$acl_name       = '',
	$use_backend	= '',
	$extra_acls		= [],
	$file_template	= 'haproxy/fragment_acl.erb'
) {

	$acl = $acl_name ? {
		''		=> $name,
		default => $acl_name,
	}

	@@concat::fragment { "${listen_name}_acl_${acl}":
		content => template($file_template),
        tag     => "listenblock_${listen_name}",
        target  => "/tmp/haproxy_listen_${listen_name}.tmp",
        order   => '302',
	}

	if $use_backend != '' {
        $acls = concat([ $acl ], $extra_acls)
		
		haproxy::listen::use_backend { "listen-${use_backend}-${acl}":
			listen_name   => $listen_name,
			backend_name	=> $use_backend,
			if_acl			=> $acls,
		}
	}


}
