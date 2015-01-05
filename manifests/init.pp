# == Class: mesos
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
class adobe_em6 (
  $cms_group              = 'aem',
  $cms_user               = 'aem',
  $dir_cms_install_base   = '/data/apps/aem',
  $dir_cms_log_base       = '/data/logs/aem',
  $dir_tools_base         = '/data/tools/aem',
  $dir_tools_log          = '/data/logs/tools/aem',
  $java_version           = 'present',
) {

  include adobe_em6::pre_install

}
