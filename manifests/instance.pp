# == Define: adobe_em::instance
#
# Adobe EM PP file to create, install and config specific setting to an author or publish
#
# === Parameters:
#
# [*instance_type*]
#   Either 'author' or 'publish'
# [*instance_port*]
#   The port to run this instance on.
# [*service_enable*]
#   Either true or false to enable the AEM service
# [*service_ensure*]
#   Either stopped or running to control the running state of the service.  Disable(UNSET) by default
# [*start_aem_env*]
#   An environment name that will be used by OSGi configs. This is used in the start.erb template.
# [*start_classpath*]
#   Start template variable to add jars to the classpath
# [*start_file_size_limit*]
#   Start template variable to set open file size use by AEM
# [*start_host*]
#   Start template variable to set AEM host name
# [*start_jaas_config*]
#   Start template variable to set the JAAS configuration file for AEM
# [*start_jvm_aem_args*]
#   Start template variable to set JVM args used specifally by AEM
# [*start_jvm_keystore_args*]
#   Start template variable to set a JVM keystore which is picked up by AEM
# [*start_jvm_memory_args*]
#   Start template variable to set JVM Memory args (i.e. memory size, GC collector)
# [*start_jvm_monitor_args*]
#   Start template variable to set any JVM args that are required by your monitoring software (i.e. agent, jmx)
# [*start_jvm_property_args*]
#   Start template variable to set any JVM property (i.e. -D args)
# [*start_use_jaas*]
#   Start template variable to enable the use of the JAAS configuration file.
# [*update_upldate*]
#   An array of AEM update, service packs, and hotfixes filenames
#
# === External Parameters

# [*adobe_em6::params::aem_user*]
#   User that will own AEM related files
# [*adobe_em6::params::aem_group*]
#   Group that will own AEM related files
# [*adobe_em6::params::dir_aem_log*]
#   Base AEM log directory
# [*adobe_em6::params::aem_absolute_jar*]
#   Full path include filename that aem jar will go
#
# === Examples:
#
  # $aem_instances = hiera_hash('myname::adobe_em6::aem_instances')
  # create_resources('adobe_em6::instance', $aem_instances)
  #
  # adobe_em6::instance { 'author':
  #   # instance_type extracts 'author' from name
  #   # instance_port defaults to '4502'
  # }
  #
  # adobe_em6::instance { 'publish':
  #   # instance_type extracts 'publish' from name
  #   # instance_port defaults to '4503'
  # }
  #
  # adobe_em6::instance { 'author01':
  #   instance_type => 'author',
  #   instance_port => '4504',
  # }
  #
  # adobe_em6::instance { 'publish01':
  #   instance_type          => 'publish',
  #   instance_port          => '4505',
  #   update_list            => [ 'AEM_6.0_Service_Pack_2-1.0.zip', 'cq-6.0-featurepack-4137-1.0.zip' ]
  # }
define adobe_em6::instance (
  $instance_type              = 'UNSET',
  $instance_port              = 'UNSET',
  $service_enable             = 'true',
  $service_ensure             = 'UNSET',
  $start_aem_env              = 'dev',
  $start_classpath            = '/usr/java/latest/lib/tools.jar',
  $start_file_size_limit      = '8192',
  $start_host                 = '',
  $start_jaas_config          = 'etc/jaas.conf',
  $start_jvm_aem_args         = '',
  $start_jvm_keystore_args    = '',
  $start_jvm_memory_args      = '-Xmx1024m -XX:MaxPermSize=256M',
  $start_jvm_monitor_args     = '',
  $start_jvm_property_args    = '',
  $start_jaas_config          = 'etc/jaas.conf',
  $start_use_jaas             = '',
  $update_list                = [ 'AEM_6.0_Service_Pack_2-1.0.zip' ],
) {

  require adobe_em6

  ##################################
  ###  Instance's type and port check and other verifications
  if ($instance_type == 'UNSET' or $instance_port == 'UNSET') {
    if ($name == 'author') {
      $my_type      = 'author'
      $my_port      = '4502'
    }
    elsif ($name == 'publish') {
      $my_type = 'publish'
      $my_port = '4503'
    }
    else {
      fail('Not using default titles of publish or author, so need to set the instance_type and instance_port')
    }
  }
  else { # both parameters were passes in
    if !($instance_type in ['author', 'publish']) {
      fail("'${instance_type}' is not a valid 'instance_type' property. Should be 'author' or 'publish'.")
    }

    if $instance_port !~ /^\d{3,5}$/ {
      fail("'${instance_port}' is not a valid 'instance_port' property. Should be a number.")
    }

    $my_type  = $instance_type
    $my_port  = $instance_port
  }

  validate_array($update_list)

  ##################################
  ###  Instance's directory creation
  File {
    owner   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group,
    mode    => '0755',
  }

  file { "${adobe_em6::params::dir_aem_install}/${title}":
    ensure  => 'directory',
    require => File[ $adobe_em6::params::dir_aem_install ],
  }

  file { "${adobe_em6::params::dir_aem_log}/${title}":
    ensure  => 'directory',
    require => File[ $adobe_em6::params::dir_aem_log ],
  }

  ##################################
  ### Jar Unpacking
  exec { "unpack_crx_jar_for_${title}":
    command => "/usr/bin/java -jar ${adobe_em6::params::aem_absolute_jar} -unpack",
    cwd     => "${adobe_em6::params::dir_aem_install}/${title}",
    user    => $adobe_em6::params::aem_user,
    creates => "${adobe_em6::params::dir_aem_install}/${title}/crx-quickstart",
    path    => ['/bin', '/usr/java/latest/bin/', '/usr/bin'],
    require => [ Exec[ 'download_aem_jar' ], Package[ 'java' ] ]
  }

  ##################################
  ### Applying Updates
  ##Creating install directory and downloading update packages.
  #
  ## This can be converted to an iteration feature starting in Puppet 3.2
  ## for now making the array a hash and using a create_resource to call the define type apply_updates
  $aem_update_hash = generate_resource_hash($update_list, 'filename', "${title}_update")

  file { "${adobe_em6::params::dir_aem_install}/${title}/crx-quickstart/install":
    ensure  => 'directory',
    require => Exec[ "unpack_crx_jar_for_${title}" ],
  }

  adobe_em6::instance::apply_updates_wrapper { "${title}_update_wrapper":
    update_hash => $aem_update_hash,
    require     => File[ "${adobe_em6::params::dir_aem_install}/${title}/crx-quickstart/install" ],
  }

  ##################################
  ### Customizing AEM files
  ## Having scope issue with templates using instance/post_intall_config.pp and reference instance params.
  file { "${adobe_em6::params::dir_aem_install}/${title}/license.properties":
    ensure  => 'present',
    content => template('adobe_em6/license.properties.erb'),
    require => Exec[ "unpack_crx_jar_for_${title}" ],
 }

  file { "${adobe_em6::params::dir_aem_install}/${title}/crx-quickstart/bin/start":
    ensure  => 'present',
    content => template('adobe_em6/start.erb'),
    require => Exec[ "unpack_crx_jar_for_${title}" ],
  }

  file { "${adobe_em6::params::dir_aem_install}/${title}/crx-quickstart/logs":
    ensure  => 'link',
    target  => "${adobe_em6::params::dir_aem_log}/${title}",
    replace => true,
    force   => true,
    require => Exec[ "unpack_crx_jar_for_${title}" ],
  }

  #Files to add:
  #config/sling.properties
  #config/ldap.conf
  #What file are now workspace.xml and repository.xml
  #What about custom configurations

  ##################################
  ### Creating AEM service
  if !($service_enable in ['true', 'false', 'manual']) {
    fail("'${service_enable}' is not a valid 'enable' property. Should be 'true', 'false' or 'manual'.")
  }
  file { "/etc/init.d/aem_${title}":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0744',
    content => template("adobe_em6/aem_type.erb"),
  }

 if ($service_ensure == 'UNSET') {
    service { "set up service for ${title}" :
      enable  => $service_enable,
      name    => "aem_${title}",
      require => File["/etc/init.d/aem_${title}"],
    }
  }
  else {
    if !($service_ensure in ['running', 'true', 'stopped', 'false']) {
      fail("'${service_ensure}' is not a valid 'ensure' property. Should be 'running', 'true', 'stopped' or 'false'.")
    }

    service { "set up service for ${title}" :
      enable      => $service_enable,
      ensure      => $service_ensure,
      hasrestart  => true,
      hasstatus    => true,
      name        => "aem_${title}",
      require     => [ File["/etc/init.d/aem_${title}"],
        File["${adobe_em6::params::dir_aem_install}/${title}/crx-quickstart/bin/start"],
        File["${adobe_em6::params::dir_aem_install}/${title}/license.properties"]
      ]
    }
  }

}