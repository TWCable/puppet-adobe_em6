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

  package { 'ruby' :
    ensure => '1.8.7.374-4.el6_6'
  }

  package { 'rubygems' :
    ensure => '1.3.7-5.el6',
    require => Package[ 'ruby' ]
  }

  package { 'json_pure' :
    provider => 'gem',
    ensure => "1.8.2",
    require => Package[ 'ruby' ]
  }

  file { "${adobe_em6::params::dir_tools}/aem_bundle_status.rb":
    ensure  => 'present',
    source  => 'puppet:///modules/adobe_em6/aem_bundle_status.rb',
    require => [ File[ $adobe_em6::params::dir_tools ], Package[ 'ruby' ], Package[ 'json_pure' ] ]
  }

}
