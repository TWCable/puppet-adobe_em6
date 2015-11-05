# == Class: adobe_em6
#
# This module manages setup and installs of
#     Adobe Enterprise Manager 6.X and related packages
#
# == Parameters:
#
# === Examples
#
#
# === Authors
#
#  Jeff Scelza <jeffscelza76@gmail.com>
#
# === Copyright
#
#
class adobe_em6 inherits adobe_em6::params {

  require adobe_em6::pre_install_directory
  require java
  require wget
  require adobe_em6::tools


  if $adobe_em6::params::remote_keystore_location != 'UNSET' {
    exec { 'Check to see if the keystore is up-to-date, and update if not...':
      command => "wget -N -P ${dir_aem_certs} ${adobe_em6::params::remote_keystore_location}",
      logoutput => false,
      timeout => $adobe_em6::params::exec_download_timeout,
      user => $adobe_em6::params::aem_user,
      path => '/bin:/usr/bin'
    }
  }

  if $adobe_em6::params::remote_truststore_location != 'UNSET' {
    exec { 'Check to see if the truststore is up-to-date, and update if not...':
      command => "wget -N -P ${dir_aem_certs} ${adobe_em6::params::remote_truststore_location}",
      logoutput => false,
      timeout => $adobe_em6::params::exec_download_timeout,
      user => $adobe_em6::params::aem_user,
      path => '/bin:/usr/bin'
    }
  }

}
