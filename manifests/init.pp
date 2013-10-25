# = Class haproxy
#
# This class install HaProxy with some configurable params
#
# == Params
#
# [*service_ensure*]
#   status of the service. Boolean or running|stopped. Default: true
#
# [*service_enable*]
#   service enabled by default. Boolean. Default: true
#
# [*file_template*]
#
# [*log_file*]
#   false do not log on file. otherwise pathfile (syslog_facility become mandatory). If file enable logrotate
#
# [*file_template*]
#   template used to override default configuration
#
# [*syslog_facility*]
#   facility to use for redirect rsyslog log
#
# [*enable_stats*]
#   enable stats page
#
# [*enable_hatop*]
#   enable hatop by installing package and setting user/group
#
# [*enabled*]
#   service must be enabled by default. Default: true
#
# [*running*]
#   service must be running
#
# [*maxconn*]
#   global maxconn
#
# [*default_mode*]
#   default mode
#
# [*options*]
#   default options array
#
# [*contimeout*]
#   haproxy param. Default: 5000
#
# [*clitimeout*]
#   haproxy param. Default: 50000
#
# [*srvtimeout*]
#   haproxy param. Default: 50000
#
# [*enable_hatop*]
#   install hatop and start service as root
#
# [*enable_stats*]
#   Abilita pagina di stats
#
# [*stats_user*]
#   stats username
#
# [*stats_pass*]
#  stats password
#
# [*monitor*]
#   enable monitor of process haproxy and hastats
#
# [*nagios_hostname*]
#   hostname of nagios server used for monitoring
#
# [*HA*]
#   if true, installation must support bind on non local ip to work in HA mode
#
class haproxy (
  $service_ensure   = running,
  $service_enable   = true,
  $log_file         = '',
  $logserver        = '127.0.0.1',
  $file_template    = '',
  $syslog_facility  = 'local1',
  $enable_stats     = true,
  $enable_hatop     = true,
  $maxconn          = 2000,
  $contimeout       = 5000,
  $clitimeout       = 50000,
  $srvtimeout       = 50000,
  $retries          = 2,
  $srvtimeout       = 50000,
  $default_mode     = 'tcp',
  $options          = '',
  $stats_user       = 'haproxystats',
  $stats_pass       = '',
  $monitor          = true,
  $nagios_hostname  = '',
  $HA               = true,
) {

  include haproxy::params

  if $log_file != '' {
    validate_absolute_path($log_file)
  }

  validate_bool($enable_stats)
  validate_bool($enable_hatop)
  validate_bool($monitor)
  validate_bool($service_enable)
  validate_bool($HA)

  if ($service_ensure != false) and ($service_ensure != true) and ($service_ensure != 'running') and ($service_ensure != 'stopped') {
    fail ('service_ensure must be boolean or running|stopped')
  }

  if !is_integer($maxconn) {
    fail ('maxconn should be an integer value')
  }

  if !is_integer($contimeout) {
    fail ('contimeout should be an integer value')
  }

  if !is_integer($clitimeout) {
    fail ('clitimeout should be an integer value')
  }

  if !is_integer($srvtimeout) {
    fail ('srvtimeout should be an integer value')
  }

  if ($default_mode != 'http') and ($default_mode != 'tcp') {
    fail ('default_mode must be one of http|tcp')
  }

  if ($enable_stats and (($stats_user == '') or ($stats_pass == ''))) {
    fail('if enable_stats is true you must specify stats_user and stats_pass')
  }

  if ($monitor) and ($nagios_hostname=='') {
    fail ('if monitor is true you have to specify nagios_hostname')
  }

  if !$syslog_facility {
    fail ('Please specify a syslog_facility')
  }

  $array_options = is_array($options)? {
    true  => $options,
    false => [ $options ]
  }

  $haproxy_user_group = $enable_hatop ? {
    true  => 'root',
    false => 'haproxy'
  }

  if $log_file != '' {
    rsyslog::facility { 'haproxy':
      log_file       => $log_file,
      file_template  => 'haproxy/rsyslog_facility.erb',
      logrotate      => false,
    }
  }

  include haproxy::install
  include haproxy::config
  include haproxy::service

  Class['haproxy::install'] ->
  Class['haproxy::config'] ->
  Class['haproxy::service']

  if $HA {
    sysctl::conf{'10-bind.conf':
      key     => 'net.ipv4.ip_nonlocal_bind',
      value   => 1
    }
  }

  /*if ($log_file!='') {
    include haproxy::logrotate
    Class['haproxy::service'] ->
    Class['haproxy::logrotate']
  }

  if ($monitor) {
    include haproxy::monitoring
    Class['haproxy::service'] ->
    Class['haproxy::monitoring']
  }*/
}
