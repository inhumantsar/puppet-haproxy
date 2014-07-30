# = Define haproxy::backend
#
#	 This define creates a fragment with backend definitions
#
# == Params
#
# [*backend_name*]
#	backend's name. <name> will be used if it's not defined
#
# [*file_template*]
#	 if customized template should be used.
#
# [*options*]
#	 hash of haproxy options available to backends. accepts arrays for duplicate keys.
#    eg: options => { 'option' => [ 'httpclose', 'forwardfor' ], 'balance' => 'roundrobin', }
#
# [*mode*]
#	 http, tcp or, if mode is specified in defaults, a blank string
#
# [*servers*]
#    hash containing server definitions. see haproxy::backend::server for param details
#
define haproxy::backend (
	$backend_name	    = '',
	$file_template	    = 'haproxy/haproxy_backend_header.erb',
	$options		    = {
        'balance'   => 'roundrobin',
    },
	$mode			    = '',
    $servers            = {},
) 
{
	if ($mode != 'http') and ($mode != 'tcp') and ($mode != '') {
		fail ('Mode must be http, tcp or, if mode is specified in defaults, a blank string')
	}

	$be_name = $backend_name ? {
		''		=> $name,
		default => $backend_name
	}

    ### start a temp file for each backend
    concat { "/tmp/haproxy_backend_${be_name}.tmp" : }

    ### add backend
    @@concat::fragment { "${be_name}_backend_header":
        content => template($file_template),
        tag     => "backendblock_${be_name}",
        target  => "/tmp/haproxy_backend_${be_name}.tmp",
        order   => '200',
    }

    ### add servers, if applicable
    $server_defaults = { 'backend' => "${be_name}" }
    create_resources('haproxy::backend::server', $servers, $server_defaults)

    ### collect and realise all acls, servers, etc. associated with the backend
    Concat::Fragment <<| tag == "backendblock_${be_name}" |>>

    ### add contents of temp file to main config file
    # i really dislike using lookups like haproxy::config_dir but it works
    concat::fragment { "${be_name}_backend_block" :
        source  => "/tmp/haproxy_backend_${be_name}.tmp",
        target  => "${haproxy::config_dir}/haproxy.cfg",
        order   => '105',
    }

}


