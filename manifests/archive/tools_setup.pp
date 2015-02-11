# == Class: adobe_em6::tools_setup
#
#  Set up tools files and scripts.
#  Crons should be set up within the adobe_em6::instance class to allow multiple instance to run on same hosts
#
# == Parameters:
#
# [*PARAMS*] - What is it?
#
# === Examples
#
# === Authors
#
#  Jeff Scelza <jeffscelza76@gmail.com>
#
# === Copyright
#
#
class adobe_em6::tools_setup {

  file { 'create consistencyCheck.sh' :
    ensure  => 'present',
    path    => "${adobe_em::dir_tools}/consistencyCheck.sh",
    content => template('adobe_em/consistencyCheck.sh.erb'),
    mode    => '0744',
    require => [ File[ 'create aem tools log directory' ], File[ 'create aem tools directory' ] ],
  }

  file { 'create aemGarbageCollection.sh' :
    ensure  => 'present',
    path    => "${adobe_em::dir_tools}/aemGarbageCollection.sh",
    content => template('adobe_em/aemGarbageCollection.sh.erb'),
    mode    => '0744',
    require => [ File[ 'create aem tools log directory' ], File[ 'create aem tools directory' ] ],
  }

  cron { "cron for ${cms_type} consistencyCheck.sh" :
    ensure  => $adobe_em::consistencyCheck_cron_status,
    command => "${adobe_em::dir_tools}/consistencyCheck.sh ${cms_type} > ${adobe_em::dir_tools_log}/consistencyCheck.${cms_type}.out 2>&1",
    user    => $adobe_em::cms_user,
    hour    => $adobe_em::consistencyCheck_cron_hour,
    minute  => $adobe_em::consistencyCheck_cron_minute,
  }

  cron { "cron for ${cms_type} Default aemGarbageCollection.sh" :
    ensure  => $adobe_em::aemGarbageCollection_cron_status,
    command => "${adobe_em::dir_tools}/aemGarbageCollection.sh ${cms_type} > ${adobe_em::dir_tools_log}/aemGarbageCollection.${cms_type}.out 2>&1",
    user    => $adobe_em::cms_user,
    hour    => $adobe_em::aemGarbageCollection_cron_hour,
    minute  => $adobe_em::aemGarbageCollection_cron_minute,
  }

  cron { "cron for ${cms_type} Classic aemGarbageCollection.sh" :
    ensure  => $adobe_em::aemGarbageCollection_Classic_cron_status,
    command => "${adobe_em::dir_tools}/aemGarbageCollection.sh ${cms_type} Classic > ${adobe_em::dir_tools_log}/aemGarbageCollection.Classic.${cms_type}.out 2>&1",
    user    => $adobe_em::cms_user,
    hour    => $adobe_em::aemGarbageCollection_Classic_cron_hour,
    minute  => $adobe_em::aemGarbageCollection_Classic_cron_minute,
  }

}