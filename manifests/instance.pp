# == Define: adobe_em::instance
#
# Adobe EM PP file to create, install and config specific setting to an author or publish
#
# === Parameters:
#
# [*aem_type*]
#   Either 'author' or 'publish'
# [*aem_port*]
#   The port to run this instance on.
# [*aem_update_list*]
#   An array of AEM update, service packs, and hotfixes filenames
#   [ 'AEM_6.0_Service_Pack_2-1.0.zip', 'cq-6.0-featurepack-4137-1.0.zip', 'cq-6.0.0-hotfix-4135-1.0.2.zip' ]
#
# === Examples:
#
  # $aem_instances  = hiera_hash('myname::adobe_em6::aem_instances')
  # create_resources('adobe_em6::instance', $aem_instances)

  # adobe_em6::instance { 'author':
  #   # aem_type extracts 'author' from name
  #   # aem_port defaults to '4502'
  # }

  # adobe_em6::instance { 'publish':
  #   # aem_type extracts 'publish' from name
  #   # aem_port defaults to '4503'
  # }

  # adobe_em6::instance { 'author01':
  #   aem_type => 'author',
  #   aem_port => '4504',
  # }

  # adobe_em6::instance { 'publish01':
  #   aem_type => 'publish',
  #   aem_port => '4505',
  # }


define adobe_em6::instance (
  $aem_type           = 'UNSET',
  $aem_port           = 'UNSET',
  $aem_update_list    = [ 'AEM_6.0_Service_Pack_2-1.0.zip' ],
) {

  if !defined( "adobe_em6") {
    notify {'Class Adobe_em6 not explicitly defined.  Please add" \"include adobe_em6\" to your respected configurations':}
  }

  include adobe_em6::params

  if ($aem_type == 'UNSET' or $aem_port == 'UNSET') {
    if ($name == 'author') {
      $my_type      = 'author'
      $my_port      = '4502'
    }
    elsif ($name == 'publish') {
      $my_type = 'publish'
      $my_port = '4503'
    }
    else {
      fail('Not using default titles of publish or author, so need to set the aem_type and aem_port')
    }
  }
  else { # both parameters were passes in
    if !($aem_type in ['author', 'publish']) {
      fail("'${aem_type}' is not a valid 'aem_type' property. Should be 'author' or 'publish'.")
    }

    if $aem_port !~ /^\d{3,5}$/ {
      fail("'${aem_port}' is not a valid 'aem_port' property. Should be a number.")
    }

    $my_type  = $aem_type
    $my_port  = $aem_port
  }

  validate_array($aem_update_list)

  ##################################
  ###  Instance's directory creation
  File {
    owner   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group,
    mode    => '0755',
  }

  file { "${adobe_em6::params::dir_aem_install}/${title}":
    ensure  => 'directory',
    path    => "${adobe_em6::params::dir_aem_install}/${title}",
    require => File[ $adobe_em6::params::dir_aem_install ],
  }

  # file { "${adobe_em6::params::dir_aem_install}/${title}/crx-quickstart":
  #   ensure  => 'directory',
  #   path    => "${adobe_em6::params::dir_aem_install}/${title}/crx-quickstart",
  #   require => File[ "${adobe_em6::params::dir_aem_install}/${title}" ],
  # }

  file { "${adobe_em6::params::dir_aem_log}/${title}":
    ensure  => 'directory',
    path    => "${adobe_em6::params::dir_aem_log}/${title}",
    require => File[ $adobe_em6::params::dir_aem_log ],
  }

  ##################################
  ### Jar Set up
  ### These steps should really be its own resource/function
  $aem_jar = "${adobe_em6::params::dir_aem_install}/${title}/cq5-${my_type}-p${my_port}.jar"

  file { "create_crx_jar_link_for_${title}":
    ensure  => 'link',
    target  => "${adobe_em6::params::dir_aem_install}/${adobe_em6::params::pkg_aem_jar_name}",
    path    => $aem_jar,
    replace => true,
    force   => true,
  }

  exec { "unpack_crx_jar_for_${title}":
    command => "/bin/bash -c \"source ~/.bash_profile && java -jar ${aem_jar} -unpack\"",
    cwd     => "${adobe_em6::params::dir_aem_install}/${title}",
    user    => $adobe_em6::params::aem_user,
    creates => "${adobe_em6::params::dir_aem_install}/${title}/crx-quickstart",
    path    => ['/bin', '/usr/java/latest/bin/'],
    require => File[ "create_crx_jar_link_for_${title}" ],
  }

  ##################################
  ### Applying Updates
  ##Creating install directory and downloading update packages.
  #
  ## This can be converted to an iteration feature starting in Puppet 3.2
  ## for now making the array a hash and using a create_resource to call the define type apply_updates
  $aem_update_hash = generate_resource_hash($aem_update_list, 'filename', "${title}_update")

  file { "${adobe_em6::params::dir_aem_install}/${title}/crx_quickstart/install":
    ensure  => 'directory',
    path    => "${adobe_em6::params::dir_aem_install}/${title}/crx-quickstart/install",
    require => Exec[ "unpack_crx_jar_for_${title}" ],
  }

  adobe_em6::instance::apply_updates_wrapper { "${title}_update_wrapper":
    update_hash => $aem_update_hash,
    require     => File[ "${adobe_em6::params::dir_aem_install}/${title}/crx_quickstart/install" ],
  }

  ##################################
  ### Customizing AEM files

}