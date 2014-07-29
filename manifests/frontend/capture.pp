# = Define haproxy::frontend::capture
#
#   capture header or cookie for logging
#
# == Params
#
# [*capture_name*]
#   if blank use <name>
#
# [*file_template*]
#   template to override with customized feature
#
# [*frontend_name*]
#   name of haproxy::frontend resource to rely
#
# [*type*]
#   cookie | respose header | request header
#
# [*length*]
#   integer
#
define haproxy::frontend::capture (
    $frontend_name,
    $file_template  = 'haproxy/frontend/capture.erb',
    $capture_name   = '',
    $capture_type   = 'cookie',
    $length         = 52,
) 
{
	if ($capture_type != 'cookie') and ($capture_type != 'request header') and ($capture_type != 'response header') {
		fail ('Type can only be: cookie | request header | response header')
	}

	if !is_integer($length) {
		fail ('Capture length must be an integer value')
	}

	$capture = $capture_name ? {
		''			=> $name,
		default     => $capture_name,
	}

	@@concat::fragment { "${frontend_name}_capture_${capture}":
        content => template($file_template),
        tag     => "frontendblock_${frontend_name}",
        target  => "/tmp/haproxy_frontend_${frontend_name}.tmp",
        order   => '301',
    }

}
