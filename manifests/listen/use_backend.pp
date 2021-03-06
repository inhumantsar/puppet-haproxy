# = Define haproxy:listen::use_backend
#
# This define add a use_backend directive if an acl is matched
#
# == Parameters
#
# [*listen_name*]
#   name of haproxy::listen to rely
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
define haproxy::listen::use_backend (
  $listen_name,
  $backend_name,
  $if_acl,
  $file_template  = 'haproxy/fragment_use_backend.erb'
) 
{
    if !is_array($if_acl) {
        $if_acl = [ $if_acl ]
    }

    @@concat::fragment { "${::fqdn}-ls-${listen_name}_acl-${if_acl}_be-${backend_name}":
        tag     => "${::fqdn}-listenblock_${listen_name}",
        content => template($file_template),
        #target  => "${haproxy::config_dir}/haproxy.cfg",
        target  => "/tmp/haproxy_listen_${listen_name}.tmp",
        order   => '303',
    }
}
