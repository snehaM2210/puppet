class profile::openstack::codfw1dev::glance(
    String $version = lookup('profile::openstack::codfw1dev::version'),
    Array[Stdlib::Fqdn] $openstack_controllers = lookup('profile::openstack::codfw1dev::openstack_controllers'),
    Stdlib::Fqdn $keystone_fqdn = lookup('profile::openstack::codfw1dev::keystone_api_fqdn'),
    String $db_pass = lookup('profile::openstack::codfw1dev::glance::db_pass'),
    Stdlib::Fqdn $db_host = lookup('profile::openstack::codfw1dev::glance::db_host'),
    String $ldap_user_pass = lookup('profile::openstack::codfw1dev::ldap_user_pass'),
    Stdlib::Absolutepath $glance_image_dir = lookup('profile::openstack::base::glance::image_dir'),
    Stdlib::Port $api_bind_port = lookup('profile::openstack::codfw1dev::glance::api_bind_port'),
    Stdlib::Port $registry_bind_port = lookup('profile::openstack::codfw1dev::glance::registry_bind_port'),
    Stdlib::Fqdn $primary_glance_image_store = lookup('profile::openstack::codfw1dev::primary_glance_image_store'),
    Array[String] $glance_backends = lookup('profile::openstack::codfw1dev::glance_backends'),
    ) {

    class {'::profile::openstack::base::glance':
        version                    => $version,
        openstack_controllers      => $openstack_controllers,
        keystone_fqdn              => $keystone_fqdn,
        db_pass                    => $db_pass,
        db_host                    => $db_host,
        ldap_user_pass             => $ldap_user_pass,
        api_bind_port              => $api_bind_port,
        registry_bind_port         => $registry_bind_port,
        primary_glance_image_store => $primary_glance_image_store,
        glance_backends            => $glance_backends,
        active                     => $::fqdn == $primary_glance_image_store,
    }
    contain '::profile::openstack::base::glance'

    # This is a no-op on the primary controller; on the spare master
    #  it allows us to sync up glance images with rsync.
    ferm::rule{'glancesync':
        ensure => 'present',
        rule   => "saddr (@resolve(${primary_glance_image_store}) @resolve(${primary_glance_image_store}, AAAA)) proto tcp dport (ssh) ACCEPT;",
    }

    class {'openstack::glance::image_sync':
        active                => ($::fqdn == $primary_glance_image_store),
        glance_image_dir      => $glance_image_dir,
        openstack_controllers => $openstack_controllers,
    }
}
