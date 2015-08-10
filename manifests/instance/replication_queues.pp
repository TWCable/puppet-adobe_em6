# == Define: adobe_em::instance::apply_updates
#
# This module should be called from the instance define type to obtain all
# updates required for initial setup.
#
# === Parameters:
#
# [**]
#
#
# === External Parameters
#
# [*adobe_em6::params::aem_user*]
#   User that will own AEM related files
# [*adobe_em6::params::aem_group*]
#   Group that will own AEM related files
# [*adobe_em6::params::dir_aem_install*]
#   Base AEM directory
# [*adobe_em6::instance::instance_type*]
#   is it an author or publish?
#
# === Examples:
#

define adobe_em6::instance::replication_queues (
  $jcr_description        = '',
  $instance_name          = 'UNSET',
  $instance_type          = 'UNSET',
  $log_level              = 'info',
  $protocol_http_expired  = 'true',
  $queue_enabled          = 'true',
  $retry_delay            = '60000',
  $transport_password     = 'admin',
  $transport_user         = 'admin',
  $transport_uri          = 'http://localhost:4503/bin/receive?sling:authRequestLogin=1',
) {

  # Using a locally scope variable to avoid longer dir names
  $tmp_queue_dir    = "${adobe_em6::params::dir_aem_install}/${instance_name}/queue_tmp"

  ##################################
  ### Instance's directory creation
  ### Need to created a directories so that a packages can be built
  File {
    owner   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group,
    mode    => '0755',
  }

  ensure_resource('file', $tmp_queue_dir, {
    'ensure' => 'directory',
    require => File[ $adobe_em6::params::dir_aem_install ],
  })

  file { "${tmp_queue_dir}/${title}":
    ensure  => 'directory',
    require => File[ $tmp_queue_dir ],
  }

  ###  Creating package Metadata directory
  file { "${tmp_queue_dir}/${title}/META-INF":
    ensure  => 'directory',
    require => File[ "$tmp_queue_dir/${title}" ],
  }

  file { "${tmp_queue_dir}/${title}/META-INF/vault":
    ensure  => 'directory',
    require => File[ "$tmp_queue_dir/${title}/META-INF" ],
  }

  file { "${tmp_queue_dir}/${title}/META-INF/vault/definition":
    ensure  => 'directory',
    require => File[ "$tmp_queue_dir/${title}/META-INF" ],
  }

  ###  Creating content directories
  file { "${tmp_queue_dir}/${title}/jcr_root":
    ensure  => 'directory',
    require => File[ "$tmp_queue_dir/${title}" ],
  }

  file { "${tmp_queue_dir}/${title}/jcr_root/etc":
    ensure  => 'directory',
    require => File[ "${tmp_queue_dir}/${title}/jcr_root" ],
  }

  file { "${tmp_queue_dir}/${title}/jcr_root/etc/replication":
    ensure  => 'directory',
    require => File[ "${tmp_queue_dir}/${title}/jcr_root/etc" ],
  }

  file { "${tmp_queue_dir}/${title}/jcr_root/etc/replication/agents.${instance_type}":
    ensure  => 'directory',
    require => File[ "${tmp_queue_dir}/${title}/jcr_root/etc/replication" ],
  }

  file { "${tmp_queue_dir}/${title}/jcr_root/etc/replication/agents.${instance_type}/${title}":
    ensure  => 'directory',
    require => File[ "${tmp_queue_dir}/${title}/jcr_root/etc/replication/agents.${instance_type}" ],
  }

  ### Creating the files for package
  file { "${tmp_queue_dir}/${title}/jcr_root/etc/replication/agents.${instance_type}/${title}/.content.xml":
    ensure  => 'present',
    content => template('adobe_em6/replication/replication_content.xml.erb'),
    require => File[ "${tmp_queue_dir}/${title}/jcr_root/etc/replication/agents.${instance_type}/${title}" ],
  }

  file { "${tmp_queue_dir}/${title}/META-INF/vault/config.xml":
    ensure  => 'present',
    content => template('adobe_em6/replication/config.xml.erb'),
    require => File[ "${tmp_queue_dir}/${title}/META-INF/vault" ],
  }

  file { "${tmp_queue_dir}/${title}/META-INF/vault/filter.xml":
    ensure  => 'present',
    content => template('adobe_em6/replication/filter.xml.erb'),
    require => File[ "${tmp_queue_dir}/${title}/META-INF/vault" ],
  }

  file { "${tmp_queue_dir}/${title}/META-INF/vault/nodetypes.cnd":
    ensure  => 'present',
    content => template('adobe_em6/replication/nodetypes.cnd.erb'),
    require => File[ "${tmp_queue_dir}/${title}/META-INF/vault" ],
  }

  file { "${tmp_queue_dir}/${title}/META-INF/vault/properties.xml":
    ensure  => 'present',
    content => template('adobe_em6/replication/properties.xml.erb'),
    require => File[ "${tmp_queue_dir}/${title}/META-INF/vault" ],
  }

  file { "${tmp_queue_dir}/${title}/META-INF/vault/settings.xml":
    ensure  => 'present',
    content => template('adobe_em6/replication/settings.xml.erb'),
    require => File[ "${tmp_queue_dir}/${title}/META-INF/vault" ],
  }

  file { "${tmp_queue_dir}/${title}/META-INF/vault/definition/.content.xml":
    ensure  => 'present',
    content => template('adobe_em6/replication/definition_content.xml.erb'),
    require => File[ "${tmp_queue_dir}/${title}/META-INF/vault/definition" ],
  }

  ### Create package to be used to install into instance
  ###
  $output_file              = "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/install/${title}_replication.zip"
  $launchpad_timestamp_file = "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/launchpad/conf/launchpad-timestamp.txt"

  exec { "create_${title}_replication_package":
    command => "zip -rq ${output_file} *",
    cwd     => "${tmp_queue_dir}/${title}",
    user    => 'aem',
    unless  => [ "/usr/bin/test ! -f ${launchpad_timestamp_file}", "/usr/bin/test -f ${output_file}" ],
    path    => ['/bin', '/usr/bin'],
    require => [  File[ "${tmp_queue_dir}/${title}/META-INF/vault/definition/.content.xml" ],
                  File[ "${tmp_queue_dir}/${title}/META-INF/vault/settings.xml" ],
                  File[ "${tmp_queue_dir}/${title}/META-INF/vault/properties.xml" ],
                  File[ "${tmp_queue_dir}/${title}/META-INF/vault/nodetypes.cnd" ],
                  File[ "${tmp_queue_dir}/${title}/META-INF/vault/filter.xml" ],
                  File[ "${tmp_queue_dir}/${title}/META-INF/vault/config.xml" ],
                  File[ "${tmp_queue_dir}/${title}/jcr_root/etc/replication/agents.${instance_type}/${title}/.content.xml" ] ]
  }

}