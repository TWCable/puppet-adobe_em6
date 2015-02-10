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

  #Need a check for User/Group exists
  Group <| title == $adobe_em6::params::aem_goup |> -> Pe_accounts::User <| title == $adobe_em6::params::aem_user |>

  require adobe_em6::pre_install_directory
  require java
  require wget

  # May want to add a log message to client to show that it downloading as long as it
  # doesn't cause the report to look like an resource has changed
  # Using exec rather then wget::Fetch do to the fact that wget:fetch/staging::file checks don't really work correctly.
  # wget::fetch using a uless which seems to run the download every time.
  # staging::file for some reason never uses the wget cache
  exec { "download_aem_jar":
    command => "wget --no-verbose -N -P '/var/cache/wget' ${adobe_em6::params::remote_url_for_files}/${adobe_em6::params::pkg_aem_jar_name}",
    cwd     => $adobe_em6::params::dir_aem_install,
    user    => $adobe_em6::params::aem_user,
    creates => $adobe_em6::params::aem_absolute_jar,
    path    => ['/bin', '/usr/bin'],
    require => package[ 'wget' ],
  }

}
