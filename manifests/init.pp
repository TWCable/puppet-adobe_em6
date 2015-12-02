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
    exec { 'Updating keystore...':
      command   =>  "mv aem_keystore.jks ${dir_aem_certs}/aem_keystore.jks; mv aem_keystore.jks.md5 ${dir_aem_certs}/aem_keystore.jks.md5",
      logoutput =>  false,
      timeout   =>  $adobe_em6::params::exec_download_timeout,
      unless    =>  "wget -O 'aem_keystore.jks' ${adobe_em6::params::remote_keystore_location}; md5sum aem_keystore.jks > aem_keystore.jks.md5; md5sum -c --status --quiet aem_keystore.jks.md5 ${dir_aem_certs}/aem_keystore.jks.md5",
      user      =>  'root',
      cwd       =>  '/tmp',
      path      =>  '/bin:/usr/bin'
    }
  }

  if $adobe_em6::params::remote_truststore_location != 'UNSET' {
    exec { 'Updating truststore...':
      command   =>  "mv aem_truststore.jks ${dir_aem_certs}/aem_truststore.jks; mv aem_truststore.jks.md5 ${dir_aem_certs}/aem_truststore.jks.md5",
      logoutput =>  false,
      timeout   =>  $adobe_em6::params::exec_download_timeout,
      unless    =>  "wget -O 'aem_truststore.jks' ${adobe_em6::params::remote_truststore_location}; md5sum aem_truststore.jks > aem_truststore.jks.md5; md5sum -c --status --quiet aem_truststore.jks.md5 ${dir_aem_certs}/aem_truststore.jks.md5",
      user      =>  'root',
      cwd       =>  '/tmp',
      path      =>  '/bin:/usr/bin'
    }
  }

}
