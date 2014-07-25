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
define haproxy::acl (
	$target_name    = '',
	$target_type    = '',
	$condition,
	$acl_name       = '',
	$use_backend	= '',
	$extra_acls		= [],
	$file_template	= 'haproxy/fragment_acl.erb'
) {

    case $target_type {
        'frontend' : {
           	if !defined(Haproxy::Frontend[$target_name]) {
        		fail ("Haproxy::Frontend[$target_name] is not defined!")
           	}
        }
        'backend' : {
         	if !defined(Haproxy::Backend[$target_name]) {
        		fail ("Haproxy::Backend[$target_name] is not defined!")
           	}
            if $use_backend != '' {
                warn ('It is utterly futile to try and specify use_backend for a backend ACL. This parameter will be ignored hard.')
            }
        }
        'listen' : {
         	if !defined(Haproxy::Listen[$target_name]) {
        		fail ("Haproxy::Listen[$target_name] is not defined!")
           	}
        }
        default: { fail("Invalid target type specified. Only 'frontend', 'backend' and 'listen' are valid.") }
    }

    if $target_name == '' {
        fail('A target frontend, backend or listen must be specified in the target_name parameter.')
    }

	$acl = $acl_name ? {
		''		=> $name,
		default => $acl_name,
	}


	concat::fragment { "haproxy+003-${frontend_name}-003-${name}.tmp":
		content => template($file_template),
        target  => "${haproxy::config_dir}/haproxy.cfg",
        order   => '303',
	}

	if $use_backend != '' and ($target_type == 'listen' or $target_type == 'frontend') {
        if !defined(Haproxy::Backend[$use_backend]) {
			fail ("No Haproxy::Backend[$use_backend] is defined!")
		}

        $acls = concat([ $acl ], $extra_acls)
		
		haproxy::use_backend { "${use_backend}-${acl}":
			target_name     => $target_name,
            target_type     => $target_type,
			backend_name	=> $use_backend,
			if_acl			=> $acls,
		}
	}


}
