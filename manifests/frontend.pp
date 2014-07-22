# = Define haproxy::frontend
#
#	 This define creates a fragment with backend definitions
#
# == Params
#
# [*frontend_name*]
#	 frontend name. <name> will be used if it's not defined
#
# [*bind*]
#	 Array of ip on which frontend must bind.
#
# [*port*]
#	 Port on which bind
#
# [*file_template*]
#	 if customized template should be used. Otherwise check backend-hostname-be_name
#
# [*defaul_backend*]
#	 default backend to use
#
# [*mode*]
#	 haproxy mode directive. Can be http or tcp. Default tcp
#
# [*options*]
#	 array of options
#
# [*own_logfile*]
#	 If true, requests on this frontend will be logged in a separate file under ${haproxy::log_dir}/frontend_name.log
#
define haproxy::frontend (
	$bind,
	$port,
	$default_backend,
	$frontend_name		= '',
	$file_template		= 'haproxy/haproxy_frontend_header.erb',
	$mode				= 'tcp',
	$options			= '',
	$own_logfile        = false,
) {

	if ($mode != 'http') and ($mode != 'tcp') {
		fail ('mode paramater must be http or tcp')
	}

	$frontend_name = $frontend_name?{
		''			=> $name,
		default => $frontend_name,
	}

	$array_bind = is_array($bind)? {
		true		=> $bind,
		default => [ $bind ],
	}

	$array_options = is_array($options)? {
		true		=> $options,
		default => [ $options ],
	}

    #### Ditching this check as bind IPs could be followed by a : or be replaced by a *	
	#$string_binds = inline_template('<% array_bind.each do |bind| -%><%= bind %> <% end -%>')
	#if $string_binds !~ /([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\ )+$/ {
	#	fail('invalid ip_address value present in bind')
	#}

	concat_fragment {"haproxy+003-${name}-001.tmp":
		content => template($file_template),
	}

	$facility_ensure = $haproxy::log_dir? {
		''			=> 'absent',
		default => $own_logfile? {
			true	=> 'present',
			false => 'absent',
		}
	}

	rsyslog::facility { "10-haproxy_${frontend_name}":
		ensure				=> $own_logfile ? {
				true	=> 'present',
				false => 'absent',
		},
		log_file			=> "haproxy_${frontend_name}.log",
		logdir				=> $haproxy::log_dir,
		file_template => 'haproxy/rsyslog_facility_frontend.erb',
		logrotate		 => false,
		rsyslog_tag	 => $frontend_name,
	}
}
