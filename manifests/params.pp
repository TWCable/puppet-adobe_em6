# == Class: adobe_em6::params
#
# This class set various Parameters for the Adobe_em6 module
#
# == Parameters:
# [*dir_base*]
#   Group used by application (default: /data)
# [*jks_source_location*]
#   Set this parameter if you would like to use a JKS for https configurations
#   The file is NOT kept within this module and shouldn't be (default: UNSET)
#   example puppet:///modules/name_of_module/filename

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

## Parameters used by
  $aem_group                  = 'aem',
  $aem_user                   = 'aem',
  $dir_base                   = '/data',
  $exec_download_timeout      = 1200,  # 20 minutes
  $remote_keystore_location   = 'UNSET',
  $license_customer_name      = 'UNSET',
  $license_product_version    = 'UNSET',
  $license_downloadid         = 'UNSET',
  $remote_url_for_files       = 'UNSET',
  $pkg_aem_jar_name           = 'AEM_6.0_Quickstart.jar',
  $remote_truststore_location = 'UNSET',
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
  $dir_aem_certs     = "${dir_base_apps}/certs"
  $dir_wget_cache    = '/var/cache/wget'

  ## Validation of variables
  validate_absolute_path($dir_aem_install)
  validate_absolute_path($dir_aem_log)
  validate_absolute_path($dir_tools)
  validate_absolute_path($dir_tools_log)
  validate_absolute_path($dir_aem_certs)
  validate_absolute_path($dir_wget_cache)

  ## Checking to ensure remote url is set
  # Need to check for format (i.e. http://blah/blah)
  if ($remote_url_for_files == 'UNSET') {
    fail('You have not set "remote_url_for_files" which should be set to the HTTP location and path of the AEM jar')
  }

  ## Checking Variables for license file.
  if ($license_customer_name == 'UNSET' or $license_product_version == 'UNSET' or $license_downloadid == 'UNSET') {
    fail('You have not set "license_customer_name", "license_product_version", or "license_downloadid"')
  }

}
