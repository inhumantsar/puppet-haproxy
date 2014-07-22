class haproxy::install {

	package { $haproxy::params::package_name :
		ensure	=> present,
	}

    # Install HATop
    # Why not use packages? Well, CentOS repos don't incl HATop by default
    # and the app hasn't been updated since Oct 2010 (as of July 2014)
    # Sure, it's not as clean as a package manager could make it but meh.
    file { '/tmp/hatop-0.7.7.tar.gz':
        ensure  => file,
        source  => 'puppet:///modules/haproxy/hatop-0.7.7.tar.gz',
    }

    file { '/tmp/install_hatop.sh':
        ensure  => file,
        source  => 'puppet:///modules/haproxy/install_hatop.sh',
        mode    => '755',
    }

    exec { '/tmp/install_hatop.sh':
        require     => File['/tmp/hatop-0.7.7.tar.gz'],
        creates     => '/usr/local/bin/hatop',
    }

}
