# == Class profile::hadoop::spark2
# Ensure that the WMF creaed spark2 package is installed,
# optionally Oozie has a spark2 sharelib.
# and optionally that the Spark 2 Yarn shuffle service is used.
#
# See also: https://docs.hortonworks.come/HDPDocuments/HDP2/HDP-2.6.0/bk_spark-component-guide/content/ch_oozie-spark-action.html#spark-config-oozie-spark2
#
# NOTE: This class is expected to be used on CDH based Hadoop installations, where
# spark 1 may also already be installed.
#
# [*install_yarn_shuffle_jar*]
#   If true, any Spark 1 yarn shuffle jars in /usr/lib/hadoop-yarn/lib will be replaced
#   With the Spark 2 one, causing YARN NodeManagers to run the Spark 2 shuffle service.
#   Default: true
#
# [*install_oozie_sharelib*]
#   If true, a Spark 2 oozie sharelib will be installed for the currently installed
#   Spark 2 version.  This only needs to happen once, so you should only
#   Set this to true on a single Hadoop client node (probably whichever one runs
#   Oozie server).
#   Default: false
#
# [*install_assembly*]
#   Deploy the spark2-assembly.zip to HDFS if not already present.
#   Set this to true on a single Hadoop client node.
#   Default: false
#
# [*deploy_hive_config*]
#   If true, the Hadoop Hive client config will be deployed in order to allow
#   to the spark deb package to add the proper symlinks and allow tools like
#   spark2-shell to use the Hive databases.
#   Default: true
#
# [*extra_settings*]
#   Map of key value pairs to add to spark2-defaults.conf
#   Default: {}
#
# [*use_kerberos*]
#   Force kerberos authentication before executing HDFS commands.
#   Default: false
#
# [*driver_port*]
#   If specified, it will add two settings to the config:
#   - spark.driver.port: $driver_port
#   Works only if spark.port.maxRetries is also specified.
#   Default: 12000
#
# [*driver_blockmanager_port*]
#   If specified, it will add the following to the config:
#   - spark.driver.blockManager.port
#   Works only if spark.port.maxRetries is also specified.
#   Default: 13000
#
# [*ui_port*]
#   If specified, it will add the following to the config:
#   - spark.ui.port
#   Works only if spark.port.maxRetries is also specified.
#   Default: 4040
#
# [*port_max_retries*]
#   If specified, it will add two settings to the config:
#   - spark.port.maxRetries: $port_max_retries
#   This allows the creation of a 100 port range for the driver,
#   and it adds it to the ferm config.
#   Default: 100
#
# [*executor_env_ld_lib_path*]
#   Explicitly set the LD_LIBRARY_PATH of Spark executors to avoid any errors
#   related to missing Hadoop native libraries (like Snappy for example). We already
#   have a similar setting in yarns-site.xml for the Application Master, but having
#   it stated in the Spark2's defaults has been proven in the past to work well
#   (especially when testing Kerberos in the Hadoop Test cluster).
#   Default: /usr/lib/hadoop/lib/native
#
# [*encryption_enabled*]
#   Enable encryption of RPC calls and IO files created by the shuffler.
#   This option is a convenient way to enable the right/suggested set of options
#   on all Spark 2 client/worker node.
#   Default: true
#
class profile::hadoop::spark2(
    $install_yarn_shuffle_jar = hiera('profile::hadoop::spark2::install_yarn_shuffle_jar', true),
    $install_oozie_sharelib   = hiera('profile::hadoop::spark2::install_oozie_sharelib', false),
    $install_assembly         = hiera('profile::hadoop::spark2::install_assembly', false),
    $extra_settings           = hiera('profile::hadoop::spark2::extra_settings', {}),
    $use_kerberos             = hiera('profile::hadoop::spark2::use_kerberos', false),
    $driver_port              = hiera('profile::hadoop::spark2::driver_port', 12000),
    $driver_blockmanager_port = hiera('profile::hadoop::spark2::driver_blockmanager_port', 13000),
    $ui_port                  = hiera('profile::hadoop::spark2::ui_port', 4040),
    $port_max_retries         = hiera('profile::hadoop::spark2::port_max_retries', 100),
    $executor_env_ld_lib_path = hiera('profile::hadoop::spark2::executor_env_ld_lib_path', '/usr/lib/hadoop/lib/native'),
    $encryption_enabled       = hiera('profile::hadoop::spark2::encryption_enabled', true),
    String $default_version   = lookup('profile::hadoop::spark::default_version', { 'default_value' => '2.4.4'}),
) {
    require ::profile::hadoop::common

    package { 'spark2': }

    # Get spark_verison from facter. Use the default provided via hiera if not set.
    $spark_version = $::spark_version ? {
        undef   => $default_version,
        default => $::spark_version
    }

    # Ensure that a symlink to hive-site.xml exists so that
    # spark2 will automatically get Hive support.
    if defined(Class['::cdh::hive']) {
        $hive_enabled = true
        file { '/etc/spark2/conf/hive-site.xml':
            ensure => 'link',
            target => "${::cdh::hive::config_directory}/hive-site.xml",
        }
    }
    else {
        $hive_enabled = false
    }

    file { '/etc/spark2/conf/spark-defaults.conf':
        content => template('profile/hadoop/spark2-defaults.conf.erb'),
    }

    # If we want to override any Spark 1 yarn shuffle service to run Spark 2 instead.
    if $install_yarn_shuffle_jar {
        # Add Spark 2 spark-yarn-shuffle.jar to the Hadoop Yarn NodeManager classpath.
        file { '/usr/local/bin/spark2_yarn_shuffle_jar_install':
            source => 'puppet:///modules/profile/hadoop/spark2/spark2_yarn_shuffle_jar_install.sh',
            mode   => '0744',
        }
        exec { 'spark2_yarn_shuffle_jar_install':
            command => '/usr/local/bin/spark2_yarn_shuffle_jar_install',
            user    => 'root',
            # spark2_yarn_shuffle_jar_install will exit 0 if the current installed
            # version of spark2 has a yarn shuffle jar installed already.
            unless  => '/usr/local/bin/spark2_yarn_shuffle_jar_install',
            require => [
                File['/usr/local/bin/spark2_yarn_shuffle_jar_install'],
                Package['hadoop-client'],
            ],
        }
    }

    # If running on an oozie server, we can build and install a spark2
    # sharelib in HDFS so that oozie actions can launch spark2 jobs.
    if $install_oozie_sharelib {
        file { '/usr/local/bin/spark2_oozie_sharelib_install':
            source  => 'puppet:///modules/profile/hadoop/spark2/spark2_oozie_sharelib_install.sh',
            owner   => 'oozie',
            group   => 'root',
            mode    => '0744',
            require => Class['::profile::oozie::server'],
        }

        kerberos::exec { 'spark2_oozie_sharelib_install':
            command      => '/usr/local/bin/spark2_oozie_sharelib_install',
            user         => 'oozie',
            # spark2_oozie_sharelib_install will exit 0 if the current installed
            # version of spark2 has a oozie sharelib installed already.
            unless       => '/usr/local/bin/spark2_oozie_sharelib_install',
            require      => File['/usr/local/bin/spark2_oozie_sharelib_install'],
            use_kerberos => $use_kerberos,
        }
    }

    if $install_assembly {
        file { '/usr/local/bin/spark2_upload_assembly.sh':
            source => 'puppet:///modules/profile/hadoop/spark2/spark2_upload_assembly.sh',
            owner  => 'hdfs',
            group  => 'root',
            mode   => '0550',
        }

        kerberos::exec { 'spark2_upload_assembly':
            command      => '/usr/local/bin/spark2_upload_assembly.sh',
            user         => 'hdfs',
            # spark2_upload_assembly.sh will exit 0 if the current installed
            # version of spark2 has a spark2-assembly.zip file already uplaoded to HDFS.
            unless       => '/usr/local/bin/spark2_upload_assembly.sh',
            require      => Package['spark2'],
            use_kerberos => $use_kerberos,
        }
    }

    if $driver_port {
        $driver_port_max = $driver_port + $port_max_retries
        ferm::service { 'spark2-driver':
            proto  => 'tcp',
            port   => "${driver_port}:${driver_port_max}",
            srange => '$ANALYTICS_NETWORKS',
        }
    }

    if $driver_blockmanager_port {
        $driver_blockmanager_port_max = $driver_blockmanager_port + $port_max_retries
        ferm::service { 'spark2-driver-blockmanager':
            proto  => 'tcp',
            port   => "${driver_blockmanager_port}:${driver_blockmanager_port_max}",
            srange => '$ANALYTICS_NETWORKS',
        }
    }

    if $ui_port {
        $ui_port_max = $ui_port + $port_max_retries
        ferm::service { 'spark2-ui-port':
            proto  => 'tcp',
            port   => "${ui_port}:${ui_port_max}",
            srange => '$ANALYTICS_NETWORKS',
        }
    }
}
