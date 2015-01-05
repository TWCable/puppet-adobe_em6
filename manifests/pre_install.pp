# == Class: adobe_em6::pre_install
#
# This module manages setup and installs of
#     adobe_em6 and related packages
#
# == Parameters:
#
# [*PARAMS*] - What is it?
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
class adobe_em6::pre_install (
  $cms_group              = $adobe_em6::cms_group,
  $cms_user               = $adobe_em6::cms_user,
  $dir_cms_install_base   = $adobe_em6::dir_cms_install_base,
  $dir_cms_log_base       = $adobe_em6::dir_cms_log_base,
  $dir_tools_base         = $adobe_em6::dir_tools_base,
  $dir_tools_log          = $adobe_em6::dir_tools_log,
  $java_version           = $adobe_em6::java_version,
) {

  if !defined( "java") {
    notify {'Java not setup.  Installing it now.':}
    class { 'java':
      version       => $java_version,
    }
  }

  File {
    owner   => $cms_user,
    group   => $cms_group,
    mode    => '0755',
  }

  file { 'create base cms base install dir':
    ensure  => 'directory',
    path    => $dir_cms_install_base,
  }

  file { 'create base cms base log dir':
    ensure  => 'directory',
    path    => $dir_cms_log_base,
  }

  file { 'create aem tools log directory':
    ensure  => 'directory',
    path    => $dir_tools_base,
  }

  file { 'create aem tools directory':
    ensure  => 'directory',
    path    => $dir_tools_log,
  }

}
