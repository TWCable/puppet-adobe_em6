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
  $aem_group                = 'aem',
  $aem_user                 = 'aem',
  $dir_base                 = '/data',
  $license_customer_name    = UNSET,
  $license_product_version  = UNSET,
  $license_downloadid       = UNSET,
  $remote_url_for_files     = UNSET,
  $pkg_aem_jar_name         = 'AEM_6.0_Quickstart.jar',
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

  ## Validation of variables
  validate_re($adobe_em6::params::aem_user, '^\w\w+$')
  validate_re($adobe_em6::params::aem_group, '^\w\w+$')
  validate_absolute_path($adobe_em6::params::dir_aem_install)
  validate_absolute_path($adobe_em6::params::dir_aem_log)
  validate_absolute_path($adobe_em6::params::dir_tools)
  validate_absolute_path($adobe_em6::params::dir_tools_log)

  ## Checking to ensure remote url is set
  # Need to check for format (i.e. http://blah/blah)
  if ($remote_url_for_files == 'UNSET') {
    fail('You have not set "remote_url_for_files" which should be set to the HTTP location and path of the AEM jar')
  }

  $aem_absolute_jar = "${adobe_em6::params::dir_aem_install}/${adobe_em6::params::pkg_aem_jar_name}"

  ## Checking Variables for license file.
  if ($license_customer_name == 'UNSET' or $license_product_version == 'UNSET' or $license_downloadid == 'UNSET') {
    fail('You have not set "license_customer_name", "license_product_version", or "license_downloadid"')
  }

}
