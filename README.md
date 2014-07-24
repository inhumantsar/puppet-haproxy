puppet-haproxy
==============

This module will manage HAProxy installation and configurations. Configuration is broken up into parts (frontend, backend, acls, etc.) to save on code reuse. This is a fork of the [fpizzurro/puppet-haproxy|https://github.com/fpizzurro/puppet-haproxy] project but has been heavily modified to provide more flexibility. Significant portions of the templates used in this project were inspired by (or in some cases, lifted directly from) the [puppetlabs-haproxy|https://github.com/puppetlabs/puppetlabs-haproxy] project.
 
## haproxy

Start by overriding any of the default settings you might wish to.

        class { 'haproxy' :
            package_name           => 'haproxy',
            service_name           => 'haproxy',
            service_ensure         => 'running',
            service_enable         => true,         # true: enable service startup at boot time
            service_reload         => true,         # true: reload the haproxy service after a config change
            service_user           => 'haproxy',
            service_group          => 'haproxy',
            sock_path              => '/var/run/haproxy/haproxy.sock',
            log_dir                => '/var/log/haproxy',
            archive_log_dir        => '/var/log',
            config_dir             => '/etc/haproxy',
            default_config_path    => '/etc/default/haproxy',
            enable_stats           => true,
            stats_user             => 'haproxystats',
            stats_pass             => '',
            enable_hatop           => true,         # true: install hatop 0.77 to /usr/local/bin
            global_options         => {
                'log'     => "127.0.0.1 local0",
                'chroot'  => '/var/lib/haproxy',
                'pidfile' => '/var/run/haproxy.pid',
                'maxconn' => '4000',
                'user'    => 'haproxy',
                'group'   => 'haproxy',
                'daemon'  => '',
                'stats'   => 'socket /var/lib/haproxy/stats'
            },
            defaults_options       => {
                'log'       => 'global',
                'stats'     => 'enable',
                'option'    => 'redispatch',
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
        }

## haproxy::backend

### Defaults

        haproxy::backend { "$name" :
            backend_name   = $name,
            file_template  = 'haproxy/haproxy_backend_header.erb',
            options        = {
                'balance'   => 'roundrobin',
            },
            mode           = 'http',
        }

### Example

#### Code

        haproxy::backend { 'articolo_http' :
            options   => {
                option  => [ 'httpclose' , 'forwardfor' ],
                balance => 'roundrobin',
            }
            mode      => 'http',
        }

#### Result

        backend articolo_http
            mode http
            balance roundrobin
            option httpclose
            option forwardfor

## haproxy::backend::server

### Defaults

        haproxy::backend::server { "$name" :
			backend_name,               # name of the backend to attach this server to
			host,                       # hostname or IP of the server
			port            = '',       # port number to connect to
			file_template   = 'haproxy/backend/server.erb',
			server_name     = '',       # optional friendly name for server
			params          = '',       # string of haproxy server params, eg: check, weight, rise, fall etc.
        }

### Basic Example

#### Code

        haproxy::backend::server { 'articolo_www01' :
            backend     => 'articolo_http',
            host        => 'www01.articolo.lan',
            port        => '8080',
            params      => 'check weight 100',
            server_name => 'www01',
        }

#### Result
    
        server www01 www01.articolo.lan:80 check weight 100

## haproxy::frontend

### Defaults

        haproxy::frontend { "$name" :
    		bind,                       # IP and port to bind to
    		default_backend,            # Name of the default backend
    		frontend_name      = '',    # Optional, $name is used if left blank
    		file_template      = 'haproxy/haproxy_frontend_header.erb',
    		mode               = 'http',
    		options            = {},    # Same format as the backend options param
        }

### Example

#### Code

        haproxy::frontend { 'articolo_www' :
            bind            => [ '*:80', '10.0.1.5:88' ]
            default_backend => 'articolo_http',
        }

#### Result

        frontend articolo_www
            bind *:80
            bind 10.0.1.5:88
            default_backend articolo_http

## haproxy::acl

ACLs can be applied to frontends, backends or listens. One of them must be specified in the parameters. A use_backend can be added to frontends and listens at this time as well. If extra acl names are needed for the use backend, they can be added with the extra_acls parameter as strings in an array.

### Defaults

        haproxy::acl { "$name" :
    		target_name,            # Name of the backend, frontend or listen to add the ACL to
    		target_type,            # Must be 'backend', 'frontend', or 'listen'.
    		condition,
    		acl_name       = '',    # Defaults to $name
    		use_backend    = '',    # Name of backend to use when matching ACL. Ignored when target_type == 'backend'
    		extra_acls     = [],    # Extra ACL names to apply to the use_backend line
        }

### Example

#### Code

        haproxy::acl { 'is_test' :
            target_name     => 'articolo_www',
            target_type     => 'frontend',
            condition       => 'hdr_beg(host) -i test.articolo.lan',
            use_backend     => 'articolo_http_test',
        }

#### Result

        frontend articolo_www
            bind *:80
            bind 10.0.1.5:88
            default_backend articolo_http
            acl is_test hdr_beg(host) -i test.articolo.lan
            use_backend articolo_http_test if is_test

## Extras

### haproxy::backend::appsession

If we want to manage persistent session, we can define one or more appsession. This should be cookies created by the application at session start. We add in the declared backend JSESSIONID but we can add more appsession cookie

        haproxy::backend::appsession {'JSESSIONID':
          backend_name  => 'articolo_http',
          length        => 52,
          timeout       => '30m',
          options       => [ 'request-learn', 'prefix' ],
        }


### haproxy::backend::add_header

Add header name X-HaProxy-Id to the request.

        haproxy::backend::add_header {'X-HaProxy-Id':
          request         => true, #(if response => true is used, header will be added on respose)
          value           => 'botolo01',
          backend_name    => 'articolo_http',
        }

Add the same header on the response
        haproxy::backend::add_header {'X-HaProxy-Id':
          response      => true, #(response and request cannot be used in conjuction)
          value         => 'botolo01',
          backend_name  => 'articolo_http',
        }

### haproxy::frontend::capture
In the defined frontend we want to capture some cookies or header that will be logged

        haproxy::frontend::capture {'JSESSIONID=':
          frontend_name => 'http':
          type          => 'cookie',
          length        => 52
        }

        haproxy::frontend::capture {'X-Backend-Id':
          frontend_name => 'http':
          type          => 'response header',
          length        => 10
        }

        haproxy::frontend::capture {'X-Varnish-Id':
          frontend_name => 'http':
          type          => 'response header',
          length        => 10
        }

### haproxy::use_backend
Create use_backend lines manually, rather than within haproxy::acl

        haproxy::use_backend { 'articolo_http':
            target_name     => 'articolo_www',
            target_type     => 'frontend',          # Can be frontend or listen
            backend_name    => 'articolo_http',
            if_acl          => [ 'acl_name' ]       # resource Haproxy::Acl['acl_name'] must exist
        }


