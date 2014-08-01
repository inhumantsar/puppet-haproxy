# = Define haproxy:frontend::use_backend
#
# This define add a use_backend directive if an acl is matched
#
# == Parameters
#
# [*frontend_name*]
#   name of haproxy::frontend to rely
#
# [*backend_name*]
#   backend to use id specified acl is matched
#
# [*if_acl*]
#   acl name that nedd to be matched
#
# [*file_template*]
#   template to use for override default template
#
define haproxy::frontend::use_backend (
  $frontend_name,
  $backend_name,
  $if_acl,
  $file_template  = 'haproxy/fragment_use_backend.erb'
) 
{
    if !is_array($if_acl) {
        $if_acl = [ $if_acl ]
    }

    @@concat::fragment { "${::fqdn}-fe-${frontend_name}_acl-${if_acl}_be-${backend_name}":
        tag     => "${::fqdn}-frontendblock_${frontend_name}",
        content => template($file_template),
        target  => "/tmp/haproxy_frontend_${frontend_name}.tmp",
        order   => '303',
    }
}
