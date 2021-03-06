class alertmanager::karma (
    String $vhost,
    Stdlib::Host $listen_address = 'localhost',
    Stdlib::Port $listen_port = 19194,
    Optional[String] $auth_header = undef,
) {
    require_package('karma')

    systemd::service { 'karma':
        ensure   => present,
        content  => init_template('karma', 'systemd_override'),
        override => true,
        restart  => true,
    }

    file { '/etc/karma.yml':
        ensure       => present,
        owner        => 'root',
        group        => 'root',
        mode         => '0444',
        content      => template('alertmanager/karma.yml.erb'),
        validate_cmd => '/usr/bin/karma --config.file % --check-config',
        notify       => Service['karma'],
    }
}
