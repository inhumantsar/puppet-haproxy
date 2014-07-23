# = Define haproxy::backend::server
#
#   add a server on specified backend
#
# == Params
#
# [*backend_name*]
#   name of haproxy::backend resource to rely
#
# [*bind*]
#   ip of the server
#
# [*port*]
#   port to use to contact server.
#
# [*file_template*]
#   if customized template should be used to override default template.
#
# [*server_name*]
#   name of server
#
# [*server_check*]
#   Boolean. If true HaProxy will perform healt check on this server. Default: true
#
# [*inter*]
#   Interval between two checks. Format: integer followed by a time suffix. Default: 5s
#
# [*downinter*]
#   interval between two checks on a down hosts. Format: same of inter. Default: 1s
#
# [*fastinter*]
#   interval between two checks when a host is coming back up. Format: same of inter. Default: 1s
#
# [*rise*]
#   Number of positive healt checks needed to consider a server up. Default: 2
#
# [*fall*]
#   Number of negative healt checks needed to consider a server down. Default: 3
#
# [*backup*]
#   true is the server have to work as backup. Default: false
#
# [*send_proxy*]
#   True if the send_proxy directive must be added. Default: false.
#
# [*weight*]
#   Weight to assign to server. interval 0(disabled) - 256 (maximum). Integer. Default: 100
#
define haproxy::backend::server 
(
  $backend_name,
  $host,
  $port,
  $file_template= 'haproxy/backend/server.erb',
  $server_name  = '',
  $params = '',
) 
{

  if !defined(Haproxy::Backend[$backend_name]) {
    fail ("No Haproxy::Backend[$backend_name] is defined!")
  }

  $server_name = $server_name ? {
    ''      => $name,
    default => $server_name,
  }

  $host = $port ? {
    ''      => $host,
    default => "${host}:${port}",
  }

  concat_fragment {"haproxy+002-${backend_name}-005-${server_name}.tmp":
    content => template($file_template),
  }
}
