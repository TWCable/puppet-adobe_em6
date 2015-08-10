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
#   Name of your instance.
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

  ##################################
  ### Instance's directory creation
  ### Need to created a directories so that a packages can be built
  File {
    owner   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group,
    mode    => '0755',
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
    require => File[ "${tmp_osgi_dir}/${title}/jcr_root/apps/system/config" ],
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

  $output_file = "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/install/${title}_osgi_config.zip"

  if ("${ensure_osgi}" == 'absent') {

    file { $output_file:
      ensure  => 'absent',
    }

  }
  elsif ("${ensure_osgi}" in ['present', 'file' ]) {
    ### Create package to be used to install into instance
    ###
    $launchpad_timestamp_file = "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/launchpad/conf/launchpad-timestamp.txt"

    exec { "create_${title}_osgi_config_package":
      command => "zip -rq ${output_file} *",
      cwd     => "${tmp_osgi_dir}/${title}",
      user    => 'aem',
      unless  => [ "/usr/bin/test ! -f ${launchpad_timestamp_file}", "/usr/bin/test -f ${output_file}" ],
      path    => ['/bin', '/usr/bin'],
      require => [  File[ "${tmp_osgi_dir}/${title}/META-INF/vault/definition/.content.xml" ],
                    File[ "${tmp_osgi_dir}/${title}/META-INF/vault/settings.xml" ],
                    File[ "${tmp_osgi_dir}/${title}/META-INF/vault/properties.xml" ],
                    File[ "${tmp_osgi_dir}/${title}/META-INF/vault/nodetypes.cnd" ],
                    File[ "${tmp_osgi_dir}/${title}/META-INF/vault/filter.xml" ],
                    File[ "${tmp_osgi_dir}/${title}/META-INF/vault/config.xml" ],
                    File[ "${tmp_osgi_dir}/${title}/jcr_root/apps/system/config/${title}.xml" ] ]
    }

  }
  else {
    fail("'${ensure_osgi}' is not a valid 'ensure' property. Should be
      'absent', 'present' or 'file'.")
  }

}