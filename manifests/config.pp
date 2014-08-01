class haproxy::config 
(
    $log_dir,
    $config_dir,
    $default_config_path,
    $service_enable,
    $service_user,
    $service_group,
    $service_reload,
    $global_options,
    $defaults_options,
)
{

	if $log_dir != false {
		file { $log_dir :
			ensure  => directory,
			mode	=> 664,
			owner	=> "${service_user}",
			group	=> "${service_group}",
		}
	}

	concat { "${config_dir}/haproxy.cfg" :
		ensure  => present,
		mode	=> '0664',
		owner	=> 'root',
		group	=> 'root',
    }

	concat::fragment { 'haproxy-config-header':
		content => template('haproxy/haproxy_header.erb'),
        target  => "${config_dir}/haproxy.cfg",
        order   => '100',
	}

	$enabled = $service_enable ? {
		true	=> 1,
		default => 0,
	}

	augeas { 'enable-haproxy':
		context => "/files${default_config_path}",
		changes => [
			"set ENABLED $enabled",
		],
	}

	file { '/var/run/haproxy':
		ensure  => directory,
		mode	=> '0755',
		owner	=> $service_user,
		group	=> $service_group,
	}

}
