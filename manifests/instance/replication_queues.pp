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
  $aem_bundle_status_user     = 'admin',
  $aem_bundle_status_passwd   = 'admin',
  $jcr_description        = '',
  $instance_name          = 'UNSET',
  $instance_type          = 'UNSET',
  $cq_template            = '/libs/cq/replication/templates/agent',
  $sling_resource_type    = 'cq/replication/components/agent',
  $log_level              = 'info',
  $protocol_http_expired  = undef,
  $protocol_http_method   = undef,
  $queue_enabled          = 'true',
  $reverse_replication    = undef,
  $retry_delay            = '60000',
  $transport_password     = 'admin',
  $transport_user         = 'admin',
  $transport_uri          = 'http://localhost:4503/bin/receive?sling:authRequestLogin=1',
  $no_versioning          = undef,
  $trigger_distribute     = undef,
  $trigger_specific       = undef,
  $trigger_on_off_time    = undef,
  $trigger_receive        = undef,
  $protocol_http_headers  = undef,
  $serialization_type     = 'durbo'
) {

  # Using a locally scope variable to avoid longer dir names
  $tmp_queue_dir = "${adobe_em6::params::dir_aem_install}/${instance_name}/queue_tmp"
  $uuid = fqdn_rand(99999, "${title}${jcr_description}${cq_template}${sling_resource_type}${queue_enabled}${log_level}${protocol_http_expired}${protocol_http_method}${retry_delay}${transport_password}${transport_user}${transport_uri}${reverse_replication}${no_versioning}${trigger_distribute}${trigger_specific}${trigger_on_off_time}${trigger_receive}${protocol_http_headers}${serialization_type}")

  ##################################
  ### Instance's directory creation
  ### Need to created a directories so that a packages can be built
  File {
    owner   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group,
    mode    => '0755',
  }

  ensure_resource('file', $tmp_queue_dir, {
    ensure => 'directory',
    require => File[ $adobe_em6::params::dir_aem_install ],
  })

  # TLD queue staging directory used to build content packages, based on queue name
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

  $requiredFiles = [ File[ "${tmp_queue_dir}/${title}/META-INF/vault/definition/.content.xml" ],
    File[ "${tmp_queue_dir}/${title}/META-INF/vault/settings.xml" ],
    File[ "${tmp_queue_dir}/${title}/META-INF/vault/properties.xml" ],
    File[ "${tmp_queue_dir}/${title}/META-INF/vault/nodetypes.cnd" ],
    File[ "${tmp_queue_dir}/${title}/META-INF/vault/filter.xml" ],
    File[ "${tmp_queue_dir}/${title}/META-INF/vault/config.xml" ],
    File[ "${tmp_queue_dir}/${title}/jcr_root/etc/replication/agents.${instance_type}/${title}/.content.xml" ] ]

  if($instance_type == 'publish') {
    $port = "4503"
  }
  else {
    $port = "4502"
  }

  ### Create package to be used to install into instance
  ###
  $package_file_name = "${title}_${uuid}_replication.zip"
  $package_file_temp = "${tmp_queue_dir}/${package_file_name}"
  $package_install_dest = "${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/install/"

  exec { "create_${title}_replication_package":
    command => "set -e ; ${adobe_em6::params::dir_tools}/aem_bundle_status.rb -a http://localhost:${port}/system/console/bundles.json -u ${aem_bundle_status_user} -p ${aem_bundle_status_passwd}; zip -rq ${package_file_temp} * ; mv -f ${package_file_temp} ${package_install_dest}",
    provider => "shell",
    cwd     => "${tmp_queue_dir}/${title}",
    user    => $adobe_em6::params::aem_user,
    subscribe => File[ "${tmp_queue_dir}/${title}/jcr_root/etc/replication/agents.${instance_type}/${title}/.content.xml" ],
    require => $requiredFiles,
    refreshonly => true,
    path    => ['/bin', '/usr/bin'],
    tries => 40,
    try_sleep => 15
  }
}
