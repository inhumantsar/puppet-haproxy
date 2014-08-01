class haproxy::service
(
    $service_name,
    $service_enable,
    $service_ensure,
    $service_reload,
)
{

	service { $service_name :
		ensure		=> $service_ensure,
		enable		=> $service_enable,
		hasrestart  => true,
		hasstatus	=> true,
	}
    
    if $service_reload {
        exec { "${service_name}_reload" :
            command     => "/sbin/service ${service_name} reload",
            subscribe   => Concat["${config_dir}/haproxy.cfg"],
        }
    }



}
