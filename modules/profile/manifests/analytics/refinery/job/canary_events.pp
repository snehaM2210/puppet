# Class: profile::analytics::refinery::job::canary_events
#
# Installs a systemd timer that produces canary events for all streams that have
# canary_events_enabled:true configured to all event intake services.
#
# By producing canary events in to these streams, we can differentiate between streams and topics
# that have no data, and ones that have a broken produce pipeline.
#
class profile::analytics::refinery::job::canary_events(
    Optional[String] $proxy_host = lookup('http_proxy_host', { 'default_value' => undef }),
    Optional[Integer] $proxy_port = lookup('http_proxy_port', { 'default_value' => undef }),
    Boolean $use_kerberos  = lookup('profile::analytics::refinery::job::canary_events::use_kerberos', { 'default_value' => true }),
    String $ensure_timers = lookup('profile::analytics::refinery::job::canary_events::ensure_timers', { 'default_value' => 'present' }),
) {

    require ::profile::analytics::refinery
    require ::profile::analytics::refinery::event_service_config

    # Update this when you want to change the version of the refinery job jar
    # being used for the job.
    $refinery_version = '0.0.135'
    $refinery_job_jar = "${::profile::analytics::refinery::path}/artifacts/org/wikimedia/analytics/refinery/refinery-job-${refinery_version}.jar"

    $event_intake_service_url_config_file = $::profile::analytics::refinery::event_service_config::event_intake_service_url_config_file

    profile::analytics::refinery::job::java_job { 'produce_canary_events':
        ensure       => $ensure_timers,
        jar          => $refinery_job_jar,
        main_class   => 'org.wikimedia.analytics.refinery.job.ProduceCanaryEvents',
        proxy_host   => $proxy_host,
        proxy_port   => $proxy_port,
        job_opts     => [
            # Only produce canary events for streams that have canary_events_enabled: true
            '--settings_filters=canary_events_enabled:true',
            # Get stream config from MediaWiki EventStreamConfig API.
            '--event_stream_config_uri=https://meta.wikimedia.org/w/api.php',
            # Read in event service name to URL mapping from this.
            "--event_service_config_uri=file://${event_intake_service_url_config_file}",
            # Actually produce canary events.
            '--dry_run=false',
        ],
        interval     => '*-*-* *:30:00',
        use_kerberos => $use_kerberos,
    }

}
