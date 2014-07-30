# = Class haproxy::logrotate
#
# This class enables logorotate of logfile created by haproxy
#
# == Params
#
# [*log_dir*]
#   string. full path to log directory.
#
class haproxy::logrotate
(
    $log_dir,
)
{
    logrotate::rule { 'haproxy' :
        path            => "${log_dir}/*.log",
        olddir          => "${log_dir}/archives",
        create          => true,
        create_mode     => '0640',
        create_owner    => 'syslog',
        create_group    => 'adm',
        compress        => true,
        rotate_every    => 'day',
        rotate          => '90',
        missingok       => true,
        ifempty         => false,
        sharedscripts   => true,
        postrotate      => 'invoke-rc.d rsyslog reload',
    }
        
}
