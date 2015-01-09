# == Class: adobe_em6::params
#
# This class set various Parameters for the Adobe_em6 module
#
# == Parameters:
# [*dir_base*] - Group used by application (default: /data)

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
class adobe_em6::params (
  $dir_base           = '/data',
) {

  # Setting Various base directories used by the installer
  # Base directory assignment
  $dir_base_apps   = "${dir_base}/apps"
  $dir_base_logs   = "${dir_base}/logs"
  $dir_base_tools  = "${dir_base}/tools"

  $dir_aem_install   = "${dir_base_apps}/aem"
  $dir_aem_log       = "${dir_base_logs}/aem"
  $dir_tools         = "${dir_base_tools}/aem"
  $dir_tools_log     = "${dir_base_logs}/tools"
  $dir_aem_certs     = "${dir_aem_install}/certs"

}
