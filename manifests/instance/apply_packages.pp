# == Define: adobe_em::instance::apply_packages
#
# This module should be called from the instance define type to obtain all
# updates required for initial setup.
#
# === Parameters:
#
# [*aem_bundle_status_passwd*]
#   The admin password to be used for the ruby script to check bundle status.
# [*aem_bundle_status_user*]
#   The admin user to be used for the ruby script to check bundle status.
# [*filename*]
#   The package name with an .zip extension that needs to be downloaded
#   for installed
# [*instance_type*]
#   Either 'author' or 'publish'
#
# === External Parameters
#
# [*adobe_em6::params::remote_url_for_files*]
#   Base HTTP, domain, and directory (excludes file name)
#
# [*adobe_em6::params::dir_aem_install*]
#   Base AEM install directory
#
# === Examples:
#


define adobe_em6::instance::apply_packages (
  $aem_bundle_status_user     = 'admin',
  $aem_bundle_status_passwd   = 'admin',
  $filename      = UNSET,
  $instance_type = UNSET
) {

  if $filename !~ /\.zip$/ {
    fail("'${filename}' is not a valid package name for 'update_file'. Name needs to contain a zip extension")
  }

  # In order to place the update file to the correct instance we need to split the
  # title which contains the instance name
  if size(split($title, '_')) >= 2 {
    $splitvals        = split($title, '_')
    $instance_name    = $splitvals[0]
  }
  else {
    fail("'${$title}' needs to contain the 'instance_name' following by '_'")
  }

  # Checking if default URL or customize one is in the file name
  if $filename =~ /^http.*/ {
    $split_filename = split($filename, '/')
    $my_filename    = $split_filename[-1]
    $my_url         = $filename
  }
  else {
    $my_filename  = $filename
    $my_url       = "${adobe_em6::params::remote_url_for_files}/${my_filename}"
  }

  File {
    owner   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group,
    mode    => '0644',
  }

  # Using exec rather then wget::Fetch do to the fact that wget:fetch/staging::file checks don't really work correctly.
  # wget::fetch using a uless which seems to run the download every time.
  # staging::file for some reason never uses the wget cache
  $hotfix_file_cache = "${adobe_em6::params::dir_wget_cache}/${my_filename}"
  $hotfix_file_tmp = "/tmp/${my_filename}"
  $hotfix_file_install = "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/install/${my_filename}"

  exec { "download_${title}_package":
    command => "wget -N -P ${adobe_em6::params::dir_wget_cache} ${my_url}",
    cwd     => '/var/cache/wget',
    user    => 'root',
    onlyif  => "test ! -f ${$hotfix_file_cache}",
    path    => ['/bin', '/usr/bin'],
    timeout => $adobe_em6::params::exec_download_timeout,
    require => Package[ 'wget' ],
  }

  if($instance_type == 'publish') {
    $port = "4503"
  }
  else {
    $port = "4502"
  }

  ## In order to ensure hotfixes don't get added prior to inital start, we have
  ## added a check on a file create after start up by AEM
  # TODO: Move to a file resource so you can add or delete base on the ensure.
  #       Will need to switch array to direct list, elimiting the need for the convert.
  exec { "copy_${filename}_hotfix_for_${instance_name}":
    command => "set -e ; ${adobe_em6::params::dir_tools}/aem_bundle_status.rb -a http://localhost:${port}/system/console/bundles.json  -u ${aem_bundle_status_user} -p ${aem_bundle_status_passwd}; cp -f ${hotfix_file_cache} ${hotfix_file_tmp} ; mv -f ${hotfix_file_tmp} ${hotfix_file_install}",
    provider => 'shell',
    cwd     => "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/install/",
    user    => $adobe_em6::params::aem_user,
    unless  => "/usr/bin/test -f ${hotfix_file_install}",
    path    => [ '/bin', '/usr/bin' ],
    require => Exec [ "download_${title}_package" ],
    tries => 40,
    try_sleep => 15
  }
}
