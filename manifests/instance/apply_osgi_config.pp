# == Define: adobe_em::instance::apply_osgi_config
#
# This module should be called from the instance define type to obtain all
# updates required for initial setup.
#
# === Parameters:
#
# [*instance_name*]
#   Name of your instance.
# [*osgi_config*]
#   Name of your configuration.
# [*aem_bundle_status_passwd*]
#   The admin password to be used for the ruby script to check bundle status.
# [*aem_bundle_status_user*]
#   The admin user to be used for the ruby script to check bundle status.

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
  $aem_bundle_status_user     = 'admin',
  $aem_bundle_status_passwd   = 'admin',
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
  $requiredFiles = [  File[ "${tmp_osgi_dir}/${title}/META-INF/vault/definition/.content.xml" ],
                      File[ "${tmp_osgi_dir}/${title}/META-INF/vault/settings.xml" ],
                      File[ "${tmp_osgi_dir}/${title}/META-INF/vault/properties.xml" ],
                      File[ "${tmp_osgi_dir}/${title}/META-INF/vault/nodetypes.cnd" ],
                      File[ "${tmp_osgi_dir}/${title}/META-INF/vault/filter.xml" ],
                      File[ "${tmp_osgi_dir}/${title}/META-INF/vault/config.xml" ],
                      File[ "${tmp_osgi_dir}/${title}/jcr_root/apps/system/config/${title}.xml" ] ]

  if($instance_name == 'publish') {
    $port = "4503"
  }
  else {
    $port = "4502"
  }

  ## Use aem_bundle_status.rb to make sure AEM has started up succesfully before deploying packages.  Will exit(1),and exec will retry if not
  exec { "Package/Deploy OSGI Config for ${title}":
    command => "set -e ; ${adobe_em6::params::dir_tools}/aem_bundle_status.rb -a http://localhost:${port}/system/console/bundles.json -u ${aem_bundle_status_user} -p ${aem_bundle_status_passwd}; /bin/rm -rf *.zip ; /usr/bin/zip -r ${package_zip_file} * ; /bin/mv -f ${package_zip_file} ${package_zip_install_folder}",
    provider => 'shell',
    cwd     => "${tmp_osgi_dir}/${title}",
    subscribe => File[ "${tmp_osgi_dir}/${title}/jcr_root/apps/system/config/${title}.xml" ],
    require => $requiredFiles,
    refreshonly => true,
    tries => 40,
    try_sleep => 15
  }

}

