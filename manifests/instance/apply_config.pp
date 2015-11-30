# == Define: adobe_em::instance::apply_config
# This module should be called from the instance define type to obtain all
# updates required for initial setup.
#
# === Parameters:
#
# [*config_name*]
#   List of the configuration variable: values to use.
# [*config_list*]
#   List of the configuration variable: values to use.
# === External Parameters
#
# [*adobe_em6::params::aem_user*]
#   User that will own AEM related files
# [*adobe_em6::params::aem_group*]
#   Group that will own AEM related files
# [*adobe_em6::params::dir_aem_install*]
#   Base AEM directory
#
# === Examples:
#
define adobe_em6::instance::apply_config (
  $config_ensure   = present,
  $config_settings = {},
  $config_file_ext = 'config',
  $dir_install     = 'UNSET',
) {

  validate_absolute_path($dir_install)

  ##################################
  ### Instance's directory creation
  ### Need to created a directories so that a packages can be built
  File {
    owner   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group,
    mode    => '0755',
  }

  file { "${dir_install}/${title}.${config_file_ext}":
    ensure  => $config_ensure,
    content => template('adobe_em6/install_config.erb'),
  }

}

