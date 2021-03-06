# profile to manage puppet
class profile::base::puppet(
  String             $puppetmaster         = lookup('puppetmaster'),
  String             $ca_server            = lookup('puppet_ca_server'),
  Stdlib::Filesource $ca_source            = lookup('puppet_ca_source'),
  Boolean            $manage_ca_file       = lookup('manage_puppet_ca_file'),
  Integer[1,59]      $interval             = lookup('profile::base::puppet::interval'),
  String             $environment          = lookup('profile::base::puppet::environment'),
  Integer[2,3]       $facter_major_version = lookup('profile::base::puppet::facter_major_version'),
  Integer[4,5]       $puppet_major_version = lookup('profile::base::puppet::puppet_major_version'),
  String             $serialization_format = lookup('profile::base::puppet::serialization_format'),
  # Looks like we need hiera version 5 to pass undef via hiera
  Optional[String] $dns_alt_names          = lookup('profile::base::puppet::dns_alt_names',
                                                    {'default_value' => undef}),
  Optional[String] $certificate_revocation = lookup('profile::base::puppet::certificate_revocation',
                                                    {'default_value' => undef}),
) {

  class { 'base::puppet':
      ca_source              => $ca_source,
      manage_ca_file         => $manage_ca_file,
      server                 => $puppetmaster,
      ca_server              => $ca_server,
      dns_alt_names          => $dns_alt_names,
      environment            => $environment,
      interval               => $interval,
      facter_major_version   => $facter_major_version,
      puppet_major_version   => $puppet_major_version,
      certificate_revocation => $certificate_revocation,
  }
  class { 'puppet_statsd':
      statsd_host   => 'statsd.eqiad.wmnet',
      metric_format => 'puppet.<%= metric %>',
  }
  class { 'prometheus::node_puppet_agent': }
}
