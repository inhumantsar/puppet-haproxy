# = Define haproxy::backend::acl
#
# This define add an haproxy acl on backend section
#
# == Parameters
#
# [*backend_name*]
#	 name of haproxy::backend resource to rely
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
define haproxy::backend::acl (
	$backend_name,
	$condition,
	$acl_name       = '',
	$extra_acls		= [],
	$file_template	= 'haproxy/fragment_acl.erb'
) {

	$acl = $acl_name ? {
		''		=> $name,
		default => $acl_name,
	}

    @@concat::fragment { "${::fqdn}-${backend_name}_acl_${acl}":
        content => template($file_template),
        tag     => "${::fqdn}-backendblock_${backend_name}",
        target  => "/tmp/haproxy_backend_${backend_name}.tmp",
        order   => '201',
    }

}
