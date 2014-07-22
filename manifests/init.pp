# = Class haproxy
#
# This class install HaProxy with some configurable params
#
# == Params TODO
#
# [*paramname*]
#	 some stuff about the param
#
class haproxy 
(
    $package_name       	= 'haproxy',
    $service_name       	= 'haproxy',
	$service_ensure	    	= 'running',
	$service_enable	    	= true,
    $service_reload     	= true,
    $service_user       	= 'haproxy',
    $service_group      	= 'haproxy',
    $sock_path          	= '/var/run/haproxy/haproxy.sock',
	$log_dir				= '/var/log/haproxy',
    $archive_log_dir    	= '/var/log',
    $config_dir         	= '/etc/haproxy',
    $default_config_path 	= '/etc/default/haproxy',
	$enable_stats			= true,
	$stats_user				= 'haproxystats',
	$stats_pass				= '',
	$enable_hatop			= true,
    $global_options         = {
        'log'     => "127.0.0.1 local0",
        'chroot'  => '/var/lib/haproxy',
        'pidfile' => '/var/run/haproxy.pid',
        'maxconn' => '4000',
        'user'    => 'haproxy',
        'group'   => 'haproxy',
        'daemon'  => '',
        'stats'   => 'socket /var/lib/haproxy/stats'
    },
	$defaults_options = {
		'log'       => 'global',
		'stats'	    => 'enable',
		'option'	=> 'redispatch',
	    'retries'   => '3',
	    'maxconn'   => '8000'
    	'timeout'   => [
			'http-request 10s',
			'queue 1m',
			'connect 10s',
			'client 1m',
			'server 1m',
			'check 10s',
		],
	},
) 
{

    ##############################################
    ### Parameter Validation & Prep
    ##############################################
    if !$package_name { fail('Please specify a package_name.') }
    if !$service_name { fail('Please specify a service_name.') }
	if ($service_ensure != false) and ($service_ensure != true) and ($service_ensure != 'running') and ($service_ensure != 'stopped') {
		fail ('service_ensure must be boolean or running|stopped')
	}
	validate_bool($service_enable)
    validate_bool($service_reload)
    if !$service_user { fail('Please specify a service_user.') }
    if !$service_group { fail('Please specify a service_group.') }
	validate_absolute_path($sock_path)
	validate_absolute_path($log_dir)
	validate_absolute_path($archive_log_dir)
	validate_absolute_path($config_dir)
	validate_absolute_path($default_config_path)
	validate_bool($enable_stats)
	if ($enable_stats and (($stats_user == '') or ($stats_pass == ''))) {
		fail('if enable_stats is true you must specify stats_user and stats_pass')
	}
	validate_bool($enable_hatop)
    if (!$global_options or $global_options == {} or $global_options == '') {
        fail('global_options empty or malformed.')
    }
    if (!$defaults_options or $defaults_options == {} or $defaults_options == '') {
        fail('defaults_options empty or malformed.')
    }


    ##############################################
    ### Logging
    ##############################################
	if $log_dir != '' {
        $log_file = 'haproxy.log'
        file { '/etc/rsyslog.d/haproxy.conf' :
            ensure          => present,
            owner           => 'root',
            group           => 'root',
            mode            => '0644',
            content         => template('haproxy/rsyslog_facility.erb'),
        }
		class { 'haproxy::logrotate' :
            log_dir => $log_dir,
        }
	}

    ##############################################
    ### The Meat
    ##############################################
    class { 'haproxy::install' :
        package_name        => $package_name,
    } ->
    class { 'haproxy::config' :
        log_dir             => $log_dir,
        config_dir          => $config_dir,
        default_config_path => $default_config_path,
        service_enable      => $service_enable,
        $service_user       => $service_user,
        $service_group      => $service_group,
    } ->
    class { 'haproxy::service' :
        service_name        => $service_name,
        service_enable      => $service_enable,
        service_ensure      => $service_ensure,
        service_reload      => $service_reload,
    }

}
