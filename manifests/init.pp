# == Class: adobe_em6
#
# This module manages setup and installs of
#     Adobe Enterprise Manager 6.X and related packages
#
# == Parameters:
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

  require adobe_em6::pre_install_directory
  require java
  require wget

  # May want to add a log message to client to show that it downloading as long as it
  # doesn't cause the report to look like an resource has changed
  # Using exec rather then wget::Fetch do to the fact that wget:fetch/staging::file checks don't really work correctly.
  # wget::fetch using a uless which seems to run the download every time.
  # staging::file for some reason never uses the wget cache
  exec { "download_aem_jar":
    command => "wget -N -P ${adobe_em6::params::dir_wget_cache} ${adobe_em6::params::remote_url_for_files}/${adobe_em6::params::pkg_aem_jar_name}",
    cwd     => $adobe_em6::params::dir_wget_cache,
    user    => 'root',
    onlyif  => "test ! -f ${adobe_em6::params::aem_absolute_jar}",
    path    => ['/bin', '/usr/bin'],
    require => Package[ 'wget' ],
    timeout => $adobe_em6::params::exec_download_timeout,
  }

  if $adobe_em6::params::jks_source_location != 'UNSET' {

    file { "${dir_aem_certs}/aem_keystore.jks":
      ensure  => 'present',
      source  => "${adobe_em6::params::jks_source_location}",
      require => File[ $dir_aem_certs ],
    }
  }

}
