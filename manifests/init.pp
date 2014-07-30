# = Class haproxy
#
# This class install HaProxy with some configurable params
#
# == Params
#
# [*package_name*]
#	string. name of the package manager package to install. default: haproxy
#
# [*service_name*]
#   string. what your OS calls the service. default: haproxy
#
# [*service_ensure*]
#   string. should puppet start/stop haproxy? default: running
#
# [*service_enable*]
#   boolean. set haproxy to launch at boot? default: true
#
# [*service_reload*]
#   boolean. reload haproxy after a config change? default: true
#
# [*service_user*]
#   string. username to run the service as. default: haproxy
#
# [*service_group*]
#   string. group to run the service under. default: haproxy
#
# [*sock_path*]
#   string. full path to socket file. default: /var/run/haproxy/haproxy.sock
#
# [*log_dir*]
#   string. full path to logging directory. default: /var/log/haproxy
#
# [*archive_log_dir*]
#   string. path to archive logs, for logrotate. default: /var/log
#
# [*config_dir*]
#   string. path to haproxy's config directory. default: /etc/haproxy
#
# [*default_config_dir*]
#   string. path to haproxy's defaults file. default: /etc/default/haproxy
#
# [*enable_stats*]
#   boolean. enable stats logging. default: true
#   NOTE: a listen stanza still needs to be configured for stats to work.
#
# [*enable_hatop*]
#   boolean. install hatop from tarball to /usr/local/bin/. default: true
#
# [*global_options*]
#   hash. override sane defaults. the hash provided will be merged with the
#         defaults listed below so you only need to provide one to override one.
#   defaults:
#			'log'     => "127.0.0.1 local0",
#			'chroot'  => '/var/lib/haproxy',
#			'pidfile' => '/var/run/haproxy.pid',
#			'maxconn' => '4000',
#			'user'    => 'haproxy',
#			'group'   => 'haproxy',
#			'daemon'  => '',
#			'stats'   => 'socket /var/lib/haproxy/stats'
#
# [*defaults_options*]
#   hash. set of values for haproxy.cfg's defaults section.
#   NOTE: if any part of this hash is overridden, the whole thing must be
#         overridden.
#   defaults:
#			'log'       => 'global',
#			'stats'     => 'enable',
#			'option'    => 'redispatch',
#			'retries'   => '3',
#			'maxconn'   => '8000',
#			'timeout'   => [
#			'http-request 10s',
#			'queue 1m',
#			'connect 10s',
#			'client 1m',
#			'server 1m',
#			'check 10s',
#			],
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
	$enable_hatop			= true,
    $global_options         = {},
	$defaults_options       = {
		'log'       => 'global',
		'stats'	    => 'enable',
		'option'	=> 'redispatch',
	    'retries'   => '3',
	    'maxconn'   => '8000',
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

    ## This is here so we can merge in overrides later.
    ## If someone only wanted to override one part of this,
    ## they would have to copy out the whole thing into
    ## their class without the merge function.
    ## defaults_options can just overridden entirely
    ## without breaking anything.
    $global_options_defaults    = {
        'log'     => "127.0.0.1 local0",
        'chroot'  => '/var/lib/haproxy',
        'pidfile' => '/var/run/haproxy.pid',
        'maxconn' => '4000',
        'user'    => 'haproxy',
        'group'   => 'haproxy',
        'daemon'  => '',
        'stats'   => 'socket /var/lib/haproxy/stats'
    }

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
	validate_bool($enable_hatop)
    if (!$global_options  or $global_options == '') {
        fail('global_options empty or malformed.')
    }
    $global_options_merged = merge($global_options_defaults, $global_options)
    
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
        service_user        => $service_user,
        service_group       => $service_group,
        global_options      => $global_options_merged,
        defaults_options    => $defaults_options,
    } ->
    class { 'haproxy::service' :
        service_name        => $service_name,
        service_enable      => $service_enable,
        service_ensure      => $service_ensure,
        service_reload      => $service_reload,
    }

}
