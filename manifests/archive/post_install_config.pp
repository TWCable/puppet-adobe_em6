# == Define: adobe_em::instance::post_install_config
#
# This module should be called from the instance define type to configure all instance specfic files.
#
# === Parameters:
#
#
# === External Parameters
#
# [*adobe_em6::params::dir_aem_install*]
#   Base AEM install directory
# [*adobe_em6::params::aem_user*]
#   User that will own AEM related files
# [*adobe_em6::params::aem_group*]
#   Group that will own AEM related files
#
# === Examples:
#


# define adobe_em6::instance::post_install_config () {

#   # In order to place the update file to the correct instance we need to split the title which contains the instance name
#   if size(split($title, '_')) >= 2 {
#     $splitvals        = split($title, '_')
#     $instance_name    = $splitvals[0]
#   }
#   else {
#     fail("'${$title}' needs to contain the 'instance_name' following by '_'")
#   }

#   File {
#     owner   => $adobe_em6::params::aem_user,
#     group   => $adobe_em6::params::aem_group,
#     mode    => '0644',
#   }

#   file { "${adobe_em6::params::dir_aem_install}/${instance_name}/license.properties":
#     ensure  => 'present',
#     content => template('adobe_em6/license.properties.erb'),
#   }

#   file { "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/bin/start" :
#     ensure  => 'present',
#     content => template('adobe_em6/start.erb'),
#   }

#   file { "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/logs":
#     ensure  => 'link',
#     target  => "${adobe_em::params::dir_aem_log}/${instance_name}",
#     replace => true,
#     force   => true,
#   }

# }