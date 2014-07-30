# = Define haproxy::backend::server
#
#	 add a server on specified backend
#
# == Params
#
# [*backend_name*]
#	 name of haproxy::backend resource to apply the server to
#
# [*host*]
#	 ip or hostname of the server
#
# [*port*]
#	 port to use to contact server
#
# [*file_template*]
#	 if customized template should be used to override default template.
#
# [*server_name*]
#	 name of server, defaults to $name
#
# [*params*]
#	 any additional parameters you might find on the server line.
#
define haproxy::backend::server 
(
	$backend,
	$host,
	$port           = '',
	$file_template  = 'haproxy/backend/server.erb',
	$server_name	= '',
	$params         = '',
) 
{
	if !defined(Haproxy::Backend[$backend]) {
		fail ("No Haproxy::Backend[$backend] is defined!")
	}

	$server = $server_name ? {
		''			=> $name,
		default => $server_name,
	}

	$address = $port ? {
		''			=> $host,
		default => "${host}:${port}",
	}

    @@concat::fragment { "${backend}_server_${name}":
        content => template($file_template),
        tag     => "backendblock_${backend}",
        target  => "/tmp/haproxy_backend_${backend}.tmp",
        order   => '203',
    }
}


