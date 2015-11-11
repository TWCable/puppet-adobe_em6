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
) {

  ##################################
  ### Instance's directory creation
  ### Need to created a directories so that a packages can be built
  File {
    owner   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group,
    mode    => '0755',
  }

  file { "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/install/${title}.config":
    ensure  => $config_ensure,
    content => inline_template("<% @config_settings.keys.sort.each do |key| %><%= key %>=<%= @config_settings[key] %>
      <% end %>"),
    require => File[ $adobe_em6::params::dir_aem_install ],
  }

}

