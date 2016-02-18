# == Class: adobe_em6::pre_install_directory
#
#  Create Directories for
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
class adobe_em6::pre_install_directory {

  File {
    owner   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group,
    mode    => '0755',
  }

  ######  Base File creation.
  if ! defined(File[$adobe_em6::params::dir_base]) {
    file { $adobe_em6::params::dir_base:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
    }
  }

  if ! defined(File[$adobe_em6::params::dir_base_apps]) {
    file { $adobe_em6::params::dir_base_apps:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      require => File[$adobe_em6::params::dir_base]
    }
  }

  if ! defined(File[$adobe_em6::params::dir_base_logs]) {
    file { $adobe_em6::params::dir_base_logs:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      require => File[$adobe_em6::params::dir_base]
    }
  }

  if ! defined(File[$adobe_em6::params::dir_base_tools]) {
    file { $adobe_em6::params::dir_base_tools:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      require => File[$adobe_em6::params::dir_base]
    }
  }

  if ! defined(File[$adobe_em6::params::dir_aem_certs]) {
    file { $adobe_em6::params::dir_aem_certs:
      ensure  => 'directory',
      require => File[$adobe_em6::params::dir_base],
    }
  }
  ######  AEM specific base directories

  file { $adobe_em6::params::dir_aem_install:
    ensure  => 'directory',
    require => File[$adobe_em6::params::dir_base_apps],
  }

  file { $adobe_em6::params::dir_aem_log:
    ensure  => 'directory',
    require => File[$adobe_em6::params::dir_base_logs],
  }

  file { $adobe_em6::params::dir_tools:
    ensure  => 'directory',
    require => File[$adobe_em6::params::dir_base_tools],
  }

  file { $adobe_em6::params::dir_tools_log:
    ensure  => 'directory',
    require => File[$adobe_em6::params::dir_base_logs],
  }

}
