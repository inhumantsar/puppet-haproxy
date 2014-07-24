# = Define haproxy:::use_backend
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
define haproxy::use_backend (
  $target_name,
  $target_type,
  $backend_name,
  $if_acl,
  $file_template  = 'haproxy/use_backend.erb'
) {
    case $target_type {
        'frontend' : {
            if !defined(Haproxy::Frontend[$target_name]) {
                fail ("Haproxy::Frontend[$target_name] is not defined!")
            }
        }
        'listen' : {
            if !defined(Haproxy::Listen[$target_name]) {
                fail ("Haproxy::Listen[$target_name] is not defined!")
            }
        }
        default: { fail("Invalid target type specified. Only 'frontend' and 'listen' are valid.") }
    }

  if !is_array($if_acl) {
    $if_acl = [ $if_acl ]
  }

  concat_fragment { "haproxy+003-${frontend_name}-004-${name}.tmp":
    content => template($file_template),
  }
}
