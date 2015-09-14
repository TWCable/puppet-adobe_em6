# == Define: adobe_em::instance::apply_osgi_config
#
# This module should be called from the instance define type to obtain all
# updates required for initial setup.
#
# === Parameters:
#
# [*ensure_present*]
#   remove or creates
# [*instance_name*]
#   Name of your instance.
# [*osgi_config*]
#   Name of your configuration.
#
# === External Parameters
#
# [*adobe_em6::params::aem_user*]
#   User that will own AEM related files
# [*adobe_em6::params::aem_group*]
#   Group that will own AEM related files
# [*adobe_em6::params::dir_aem_install*]
#   Base AEM directory
#
# === Examples:
#
define adobe_em6::instance::apply_osgi_config (
  $ensure_osgi    = 'present',
  $instance_name  = 'UNSET',
  $osgi_config    = {},
) {

  # Using a locally scope variable to avoid longer dir names
  $tmp_osgi_dir    = "${adobe_em6::params::dir_aem_install}/${instance_name}/osgi_tmp"

  ###############################################################
  #### Various properties we will need for configuration creation

  # Creates a unique identifier for a configuration.  This is useful for applying unique packages for configuration updates
  $uuid = fqdn_rand(99999, "${title}${osgi_config}")
  $time = generate("/bin/date", "+%Y-%M-%d-%T")

  ##################################
  ### Instance's directory creation
  ### Need to created a directories so that a packages can be built
  File {
    owner   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group,
    mode    => '0755',
  }

  Exec {
    user   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group
  }

  ensure_resource('file', $tmp_osgi_dir, {
    'ensure' => 'directory',
    require => File[ $adobe_em6::params::dir_aem_install ],
  })

  file { "${tmp_osgi_dir}/${title}":
    ensure  => 'directory',
    require => File[ $tmp_osgi_dir ],
  }

  ###  Creating package Metadata directory
  file { "${tmp_osgi_dir}/${title}/META-INF":
    ensure  => 'directory',
    require => File[ "${tmp_osgi_dir}/${title}" ],
  }

  file { "${tmp_osgi_dir}/${title}/META-INF/vault":
    ensure  => 'directory',
    require => File[ "${tmp_osgi_dir}/${title}/META-INF" ],
  }

  file { "${tmp_osgi_dir}/${title}/META-INF/vault/definition":
    ensure  => 'directory',
    require => File[ "${tmp_osgi_dir}/${title}/META-INF" ],
  }

  ### Creating content directories
  file { "${tmp_osgi_dir}/${title}/jcr_root":
    ensure  => 'directory',
    require => File[ "${tmp_osgi_dir}/${title}" ],
  }

  file { "${tmp_osgi_dir}/${title}/jcr_root/apps":
    ensure  => 'directory',
    require => File[ "${tmp_osgi_dir}/${title}/jcr_root" ],
  }

  file { "${tmp_osgi_dir}/${title}/jcr_root/apps/system":
    ensure  => 'directory',
    require => File[ "${tmp_osgi_dir}/${title}/jcr_root/apps" ],
  }

  file { "${tmp_osgi_dir}/${title}/jcr_root/apps/system/config":
    ensure  => 'directory',
    require => File[ "${tmp_osgi_dir}/${title}/jcr_root/apps/system" ],
  }

  ### Creating the files for package
  file { "${tmp_osgi_dir}/${title}/jcr_root/apps/system/config/${title}.xml":
    ensure  => 'present',
    content => template('adobe_em6/osgi_config/osgi.xml.erb'),
    require => File[ "${tmp_osgi_dir}/${title}/jcr_root/apps/system/config" ]
  }

  file { "${tmp_osgi_dir}/${title}/META-INF/vault/config.xml":
    ensure  => 'present',
    content => template('adobe_em6/osgi_config/config.xml.erb'),
    require => File[ "${tmp_osgi_dir}/${title}/META-INF/vault" ],
  }

  file { "${tmp_osgi_dir}/${title}/META-INF/vault/filter.xml":
    ensure  => 'present',
    content => template('adobe_em6/osgi_config/filter.xml.erb'),
    require => File[ "${tmp_osgi_dir}/${title}/META-INF/vault" ],
  }

  file { "${tmp_osgi_dir}/${title}/META-INF/vault/nodetypes.cnd":
    ensure  => 'present',
    content => template('adobe_em6/osgi_config/nodetypes.cnd.erb'),
    require => File[ "${tmp_osgi_dir}/${title}/META-INF/vault" ],
  }

  file { "${tmp_osgi_dir}/${title}/META-INF/vault/properties.xml":
    ensure  => 'present',
    content => template('adobe_em6/osgi_config/properties.xml.erb'),
    require => File[ "${tmp_osgi_dir}/${title}/META-INF/vault" ],
  }

  file { "${tmp_osgi_dir}/${title}/META-INF/vault/settings.xml":
    ensure  => 'present',
    content => template('adobe_em6/replication/settings.xml.erb'),
    require => File[ "${tmp_osgi_dir}/${title}/META-INF/vault" ],
  }

  file { "${tmp_osgi_dir}/${title}/META-INF/vault/definition/.content.xml":
    ensure  => 'present',
    content => template('adobe_em6/osgi_config/definition_content.xml.erb'),
    require => File[ "${tmp_osgi_dir}/${title}/META-INF/vault/definition" ],
  }

  $package_zip_install_folder = "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/install/"
  $package_zip_file = "${title}_${uuid}_osgi_config.zip"

  ### Create package to be used to install into instance
  ###
  $launchpad_timestamp_file = "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/launchpad/conf/launchpad-timestamp.txt"
  $requiredFiles = [  File[ "${tmp_osgi_dir}/${title}/META-INF/vault/definition/.content.xml" ],
                      File[ "${tmp_osgi_dir}/${title}/META-INF/vault/settings.xml" ],
                      File[ "${tmp_osgi_dir}/${title}/META-INF/vault/properties.xml" ],
                      File[ "${tmp_osgi_dir}/${title}/META-INF/vault/nodetypes.cnd" ],
                      File[ "${tmp_osgi_dir}/${title}/META-INF/vault/filter.xml" ],
                      File[ "${tmp_osgi_dir}/${title}/META-INF/vault/config.xml" ],
                      File[ "${tmp_osgi_dir}/${title}/jcr_root/apps/system/config/${title}.xml" ] ]


  exec { "Package/Deploy OSGI Config for ${title}":
    command => "/bin/rm -rf *.zip;/usr/bin/zip -r ${package_zip_file} *;/bin/cp ${package_zip_file} ${package_zip_install_folder}", 
    cwd     => "${tmp_osgi_dir}/${title}",
    unless  => "/usr/bin/test ! -f ${launchpad_timestamp_file}", 
    onlyif => "/usr/bin/test ${ensure_osgi} = present", #For some reason, this test does not work if placed within an 'unless' block, but works if in 'onlyif'?
    subscribe => File[ "${tmp_osgi_dir}/${title}/jcr_root/apps/system/config/${title}.xml" ],
    require => $requiredFiles, 
    refreshonly => true
  }


  if ("${ensure_osgi}" == 'absent') {
    file { "${package_zip_install_folder}${package_zip_file}":
      ensure  => 'absent',
    }
  }

}