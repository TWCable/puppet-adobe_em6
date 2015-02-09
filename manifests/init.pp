# == Class: adobe_em6
#
# This module manages setup and installs of
#     Adobe Enterprise Manager 6.X and related packages
#
# == Parameters:
#
# [*aem_group*] - Group used by application (default: aem)
# [*aem_user*] - User used by application (default: aem)

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

  ## Validation of variables
  validate_re($aem_user, '^\w\w+$')
  validate_re($aem_group, '^\w\w+$')
  validate_absolute_path($adobe_em6::params::dir_aem_install)
  validate_absolute_path($adobe_em6::params::dir_aem_log)
  validate_absolute_path($adobe_em6::params::dir_tools)
  validate_absolute_path($adobe_em6::params::dir_tools_log)

  #Need a check for User/Group exists

  include adobe_em6::pre_install_directory

  # May want to add a log message to client to show that it downloading as long as it
  # doesn't cause the report to look like an resource has changed
  wget::fetch { 'download_aem_jar':
    destination => "${adobe_em6::params::dir_aem_install}/${adobe_em6::params::pkg_aem_jar_name}",
    source      => "${adobe_em6::params::remote_url_for_files}/${adobe_em6::params::pkg_aem_jar_name}",
    timeout     => 0,
    verbose     => true,
  }

}
