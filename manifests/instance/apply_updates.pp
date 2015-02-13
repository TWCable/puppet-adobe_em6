# == Define: adobe_em::instance::apply_updates
#
# This module should be called from the instance define type to obtain all updates required for initial setup.
#
# === Parameters:
#
# [*update_file*]
#   The package name with an .zip extension that needs to be downloaded for installed
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


define adobe_em6::instance::apply_updates (
  $filename     = UNSET,
) {

  if ($filename !~ /.*\.zip/  or $filename == 'UNSET') {
    fail("'${filename}' is not a valid package name for 'update_file'. Name needs to contain a zip extension")
  }

  # In order to place the update file to the correct instance we need to split the title which contains the instance name
  if size(split($title, '_')) >= 2 {
    $splitvals        = split($title, '_')
    $instance_name    = $splitvals[0]
  }
  else {
    fail("'${$title}' needs to contain the 'instance_name' following by '_'")
  }

  File {
    owner   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group,
    mode    => '0644',
  }

  # Using exec rather then wget::Fetch do to the fact that wget:fetch/staging::file checks don't really work correctly.
  # wget::fetch using a uless which seems to run the download every time.
  # staging::file for some reason never uses the wget cache
  exec { "download_${title}_package":
    command => "wget -N -P /var/cache/wget ${adobe_em6::params::remote_url_for_files}/${filename}",
    cwd     => '/var/cache/wget',
    user    => 'root',
    onlyif  => "test ! -f ${adobe_em6::params::dir_wget_cache}/${filename}",
    path    => ['/bin', '/usr/bin'],
    require => Package[ 'wget' ],
  }

  file { "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/install/${filename}":
    ensure  => file,
    source  => "${adobe_em6::params::dir_wget_cache}/${filename}",
    require => Exec[ "download_${title}_package" ],
  }

}