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
    	exec {"${service_name} reload":
	    	command		=> "/etc/init.d/${service_name} reload",
		    refreshonly => true,
    		subscribe	=> [ Concat_build['haproxy'], File["${config_dir}subnet_softec.lst"] ]
	    }
    }

}
