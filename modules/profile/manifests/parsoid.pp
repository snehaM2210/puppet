class profile::parsoid(
    Boolean $has_lvs = lookup('has_lvs', {'default_value' => true }),
    Integer[1025, 65535] $port = lookup('profile::parsoid::port', {'default_value' => 8000}),
    Boolean $use_php = lookup('profile::parsoid::use_php', {'default_value' => false }),
) {
    if $has_lvs {
        require ::profile::lvs::realserver
    }

    if $use_php {
        require ::profile::mediawiki::php
        require ::profile::mediawiki::php::monitoring
        include ::profile::mediawiki::php::restarts
        require ::profile::mediawiki::webserver
    }

    # On beta $use_php is not set but we still need sudo for restarts (T236275)
    if $use_php or $::realm == 'labs' {
        # Temporarily allow scap3 to restart php-fpm.
        # This is going away, see T236275
        # Also yes, this is all hardcoded as it's going away soon (TM)
        sudo::user { 'scap3_restart_php':
            user       => 'deploy-service',
            privileges => [
                'ALL = (root) NOPASSWD: /usr/local/sbin/restart-php7.2-fpm',
                'ALL = (root) NOPASSWD: /bin/systemctl restart php7.2-fpm',
            ],
        }
    }

    class { '::service::configuration': }

    $mwapi_server = "${::service::configuration::mwapi_host}/w/api.php"
    class { '::parsoid':
        port         => $port,
        mwapi_server => $mwapi_server,
        mwapi_proxy  => '',
    }
}
