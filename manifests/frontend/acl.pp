# = Define haproxy::frontend::acl
#
# This define add an haproxy acl on frontend section
#
# == Parameters
#
# [*frontend_name*]
#	 name of haproxy::frontend resource to rely
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
define haproxy::frontend::acl (
	$frontend_name,
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

	@@concat::fragment { "${frontend_name}_acl_${acl}":
		content => template($file_template),
        tag     => "frontendblock_${frontend_name}",
        #target  => "${haproxy::config_dir}/haproxy.cfg",
        target  => "/tmp/haproxy_frontend_${frontend_name}.tmp",
        order   => '302',
        #require => Haproxy::Frontend[$frontend_name],
	}

	if $use_backend != '' {
        $acls = concat([ $acl ], $extra_acls)
		
		haproxy::frontend::use_backend { "frontend-${use_backend}-${acl}":
			frontend_name   => $frontend_name,
			backend_name	=> $use_backend,
			if_acl			=> $acls,
            #require         => [ Haproxy::Backend[$use_backend], Haproxy::Frontend[$frontend_name], ],
		}
	}


}
