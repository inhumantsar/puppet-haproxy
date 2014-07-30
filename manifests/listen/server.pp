# = Define haproxy::listen::server
#
#	 add a server on specified listen
#
# == Params
#
# [*listen_name*]
#	 name of haproxy::listen resource to rely
#
# [*bind*]
#	 ip of the server
#
# [*port*]
#	 port to use to contact server.
#
# [*file_template*]
#	 if customized template should be used to override default template.
#
# [*server_name*]
#	 name of server
#
# [*server_check*]
#	 Boolean. If true HaProxy will perform healt check on this server. Default: true
#
# [*inter*]
#	 Interval between two checks. Format: integer followed by a time suffix. Default: 5s
#
# [*downinter*]
#	 interval between two checks on a down hosts. Format: same of inter. Default: 1s
#
# [*fastinter*]
#	 interval between two checks when a host is coming back up. Format: same of inter. Default: 1s
#
# [*rise*]
#	 Number of positive healt checks needed to consider a server up. Default: 2
#
# [*fall*]
#	 Number of negative healt checks needed to consider a server down. Default: 3
#
# [*backup*]
#	 true is the server have to work as backup. Default: false
#
# [*send_proxy*]
#	 True if the send_proxy directive must be added. Default: false.
#
# [*weight*]
#	 Weight to assign to server. interval 0(disabled) - 256 (maximum). Integer. Default: 100
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


