# = Define haproxy::listen::server
#
#	 add a server on specified listen
#
# == Params
#
# [*listen_name*]
#    name of haproxy::listen resource to apply the server to
#
# [*host*]
#    ip or hostname of the server
#
# [*port*]
#    port to use to contact server
#
# [*file_template*]
#    if customized template should be used to override default template.
#
# [*server_name*]
#    name of server, defaults to $name
#
# [*params*]
#    any additional parameters you might find on the server line.
#
define haproxy::listen::server 
(
	$listen,
	$host,
	$port           = '',
	$file_template  = 'haproxy/listen/server.erb',
	$server_name	= '',
	$params         = '',
) 
{

	$server = $server_name ? {
		''			=> $name,
		default => $server_name,
	}

	$address = $port ? {
		''			=> $host,
		default => "${host}:${port}",
	}

    @@concat::fragment { "${listen}_server_${name}":
        content => template($file_template),
        tag     => "listenblock_${listen}",
        target  => "/tmp/haproxy_listen_${listen}.tmp",
        order   => '203',
    }

}


