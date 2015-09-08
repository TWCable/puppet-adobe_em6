# == Class: adobe_em6::tools
#
# This class manages copying out of tools and scripts for AEM
#
# == Parameters:
#
# === Examples
#
#
# === Authors
#
#
# === Copyright
#
#
class adobe_em6::tools {

  file { "${adobe_em6::params::dir_tool}/aem_bundle_status.rb":
    ensure  => 'present',
    source  => 'puppet:///modules/adobe_em6/aem_bundle_status.rb',
    require => File[ $adobe_em6::params::dir_tools ],
  }

}
