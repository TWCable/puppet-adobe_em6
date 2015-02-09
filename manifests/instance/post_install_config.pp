# == Define: adobe_em::instance::post_install_config
#
# This module should be called from the instance define type to configure all instance specfic files.
#
# === Parameters:
#
# [*name*]
#   Description
#
# === External Parameters
#
# === Examples:
#


class adobe_em6::instance::post_install_config (
  instance_name   = UNSET,
) {

  if $instance_name == 'UNSET' {
    fail("'${instance_name}' is not a valid package name for 'instance_name'.")
  }

  File {
    owner   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group,
    mode    => '0644',
  }

  file { "license.properties for ${instance_name}" :
    ensure  => 'present',
    path    => "${adobe_em6::params::dir_aem_install}/${instance_name}/license.properties",
    content => template('adobe_em6/license.properties.erb'),
  }

  # file { "start script ${instance_name}" :
  #   ensure  => 'present',
  #   path    => "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/bin/start",
  #   content => template('adobe_em6/start.erb'),
  # }


}