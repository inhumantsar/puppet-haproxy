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
	$use_backend	= '',
	$extra_acls		= [],
	$file_template	= 'haproxy/fragment_acl.erb'
) {

    if !defined(Haproxy::Backend[$backend_name]) {
        fail ("Haproxy::Backend[$backend_name] is not defined!")
    }
    if $use_backend != '' {
        warn ('It is utterly futile to try and specify use_backend for a backend ACL. This parameter will be ignored hard.')
    }

	$acl = $acl_name ? {
		''		=> $name,
		default => $acl_name,
	}

	concat::fragment { "haproxy+003-${backend_name}-003-${name}.tmp":
		content => template($file_template),
        target  => "${haproxy::config_dir}/haproxy.cfg",
        order   => '303',
	}


}
