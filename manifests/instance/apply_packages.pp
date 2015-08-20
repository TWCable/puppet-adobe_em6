# == Define: adobe_em::instance::apply_packages
#
# This module should be called from the instance define type to obtain all
# updates required for initial setup.
#
# === Parameters:
#
# [*filename*]
#   The package name with an .zip extension that needs to be downloaded
#   for installed
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
  $filename     = UNSET,
) {

  if ($filename !~ /.*\.zip/  or $filename == 'UNSET') {
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
  $cache_hotfix_filename    = "${adobe_em6::params::dir_wget_cache}/${my_filename}"
  $launchpad_timestamp_file = "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/launchpad/conf/launchpad-timestamp.txt"
  $install_hotfix_filename  = "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/install/${my_filename}"

  exec { "download_${title}_package":
    command => "wget -N -P ${adobe_em6::params::dir_wget_cache} ${my_url}",
    cwd     => '/var/cache/wget',
    user    => 'root',
    onlyif  => "test ! -f ${$cache_hotfix_filename}",
    path    => ['/bin', '/usr/bin'],
    timeout => $adobe_em6::params::exec_download_timeout,
    require => Package[ 'wget' ],
  }

  ## In order to ensure hotfixes don't get add prior to inital start we have
  ## added a check on a file create after start up by AEM
  # TODO: Move to a file resource so you can add or delete base on the ensure.
  #       Will need to switch array to direct list, elimiting the need for the convert.
  exec { "copy_${filename}_hotfix_for_${instance_name}":
    command => "cp -f ${cache_hotfix_filename} ${install_hotfix_filename}",
    cwd     => "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/install/",
    user    => $adobe_em6::params::aem_user,
    unless  => [ "/usr/bin/test ! -f ${launchpad_timestamp_file}", "/usr/bin/test -f ${install_hotfix_filename}" ],
    path    => [ '/bin', '/usr/bin' ],
    require => Exec [ "download_${title}_package" ],
  }

}