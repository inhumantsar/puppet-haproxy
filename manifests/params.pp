class haproxy::params {

	$package_name		 = 'haproxy'
	$sock				 = '/var/run/haproxy/haproxy.sock'
	$config_dir			 = '/etc/haproxy/'
	$default_config		 = '/etc/default/haproxy'
	$service_name		 = 'haproxy'
	$archive_logdir		 = '/var/log'
    
}
