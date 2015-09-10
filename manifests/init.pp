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

  if $adobe_em6::params::keystore_source_location != 'UNSET' {
    file { "${dir_aem_certs}/aem_keystore.jks":
      ensure  => 'present',
      source  => "${adobe_em6::params::keystore_source_location}",
      require => File[ $dir_aem_certs ],
    }
  }

  if $adobe_em6::params::truststore_source_location != 'UNSET' {
    file { "${dir_aem_certs}/aem_truststore.jks":
      ensure  => 'present',
      source  => "${adobe_em6::params::truststore_source_location}",
      require => File[ $dir_aem_certs ],
    }
  }

}
