# the update scripts fetching data (input) for wikistats
# and writing it to local mariadb
class wikistats::updates (
    String $db_pass,
    Wmflib::Ensure $ensure,
){

    require_package('php7.3-cli')

    file { '/var/log/wikistats':
        ensure => directory,
        mode   => '0664',
        owner  => 'wikistatsuser',
        group  => 'wikistatsuser',
    }

    # db pass for [client] for dumps
    file { '/usr/lib/wikistats/.my.cnf':
        ensure  => present,
        mode    => '0400',
        owner   => 'wikistatsuser',
        group   => 'wikistatsuser',
        content => "[client]\npassword=${db_pass}\n"
    }

    # fetch new wiki data
    wikistats::cronjob::update {
        'wp' : ensure => $ensure, hour => 0;  # Wikipedias
        'lx' : ensure => $ensure, hour => 1;  # LXDE
        'si' : ensure => $ensure, hour => 1;  # Wikisite
        'wt' : ensure => $ensure, hour => 2;  # Wiktionaries
        'ws' : ensure => $ensure, hour => 3;  # Wikisources
        'wn' : ensure => $ensure, hour => 4;  # Wikinews
        'wb' : ensure => $ensure, hour => 5;  # Wikibooks
        'wq' : ensure => $ensure, hour => 6;  # Wikiquotes
        'os' : ensure => $ensure, hour => 7;  # OpenSUSE
        'gt' : ensure => $ensure, hour => 8;  # Gentoo
        'sf' : ensure => $ensure, hour => 8;  # Sourceforge
        'an' : ensure => $ensure, hour => 9;  # Anarchopedias
        'wf' : ensure => $ensure, hour => 10; # Wikifur
        'wy' : ensure => $ensure, hour => 10; # Wikivoyage
        'wv' : ensure => $ensure, hour => 11; # Wikiversities
        'wi' : ensure => $ensure, hour => 11; # Wikia
        'sc' : ensure => $ensure, hour => 12; # Scoutwikis
        'ne' : ensure => $ensure, hour => 13; # Neoseeker
        'wr' : ensure => $ensure, hour => 14; # Wikitravel
        'et' : ensure => $ensure, hour => 15; # EditThis
        'mt' : ensure => $ensure, hour => 16; # Metapedias
        'un' : ensure => $ensure, hour => 17; # Uncylomedias
        'wx' : ensure => $ensure, hour => 18; # Wikimedia Special
        'mh' : ensure => $ensure, hour => 18; # Miraheze
        'mw' : ensure => $ensure, hour => 19; # MediaWikis
        'sw' : ensure => $ensure, hour => 20; # Shoutwikis
        'ro' : ensure => $ensure, hour => 21; # Rodovid
        'wk' : ensure => $ensure, hour => 21; # Wikkii
        're' : ensure => $ensure, hour => 22; # Referata
        'ga' : ensure => $ensure, hour => 22; # Gamepedias
        'w3' : ensure => $ensure, hour => 23; # W3C
      }

    # dump xml data
    wikistats::cronjob::xmldump {
        'wp' : db_pass => $db_pass, table => 'wikipedias',   minute => 3;
        'wt' : db_pass => $db_pass, table => 'wiktionaries', minute => 5;
        'wq' : db_pass => $db_pass, table => 'wikiquotes', minute => 7;
        'wb' : db_pass => $db_pass, table => 'wikibooks', minute => 9;
        'wn' : db_pass => $db_pass, table => 'wikinews', minute => 11;
        'ws' : db_pass => $db_pass, table => 'wikisources', minute => 13;
        'wy' : db_pass => $db_pass, table => 'wikivoyage', minute => 15;
        'wx' : db_pass => $db_pass, table => 'wmspecials', minute => 1;
        'et' : db_pass => $db_pass, table => 'editthis', minute => 23;
        'wr' : db_pass => $db_pass, table => 'wikitravel', minute => 25;
        'mw' : db_pass => $db_pass, table => 'mediawikis', minute => 32;
        'mt' : db_pass => $db_pass, table => 'metapedias', minute => 37;
        'sc' : db_pass => $db_pass, table => 'scoutwiki', minute => 39;
        'os' : db_pass => $db_pass, table => 'opensuse', minute => 41;
        'un' : db_pass => $db_pass, table => 'uncyclomedia', minute => 43;
        'wf' : db_pass => $db_pass, table => 'wikifur', minute => 45;
        'an' : db_pass => $db_pass, table => 'anarchopedias', minute => 47;
        'si' : db_pass => $db_pass, table => 'wikisite', minute => 51;
        'ne' : db_pass => $db_pass, table => 'neoseeker', minute => 53;
        'wv' : db_pass => $db_pass, table => 'wikiversity', minute => 34;
        're' : db_pass => $db_pass, table => 'referata', minute => 57;
        'ro' : db_pass => $db_pass, table => 'rodovid', minute => 1;
        'lx' : db_pass => $db_pass, table => 'lxde', minute => 59;
        'sw' : db_pass => $db_pass, table => 'shoutwiki', minute => 36;
        'w3' : db_pass => $db_pass, table => 'w3cwikis', minute => 27;
        'ga' : db_pass => $db_pass, table => 'gamepedias', minute => 29;
        'sf' : db_pass => $db_pass, table => 'sourceforge', minute => 24;
        'mh' : db_pass => $db_pass, table => 'miraheze', minute => 6;
    }

    # imports (fetching lists of wikis itself) usage: <project name>@<weekday>
    wikistats::cronjob::import { [
        'miraheze@5', # https://phabricator.wikimedia.org/T153930
    ]: }

    wikistats::cronjob::import { [
        'neoseeker@7', # https://phabricator.wikimedia.org/T1262113
    ]: }
}
