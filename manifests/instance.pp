# == Define: adobe_em::instance
#
# Adobe EM PP file to create, install and config specific setting to an author
# or publish
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
#   Either stopped or running to control the running state of the service.
#   Disable(UNSET) by default
# [*start_more_modes*]
#   A comma seperate lines (no spaces) of runmodes.
#   Set your environment name that will be used by OSGi configs& other modes.
#   This is used in the start.erb template and author and publish are in the list by default.
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
#   Start template variable to set JVM Memory args (i.e.  size, collector)
# [*start_jvm_monitor_args*]
#   Start template variable to set any JVM args that are required by your
#   monitoring software (i.e. agent, jmx)
# [*start_jvm_property_args*]
#   Start template variable to set any JVM property (i.e. -D args)
# [*start_use_jaas*]
#   Start template variable to enable the use of the JAAS configuration file.
# [*stop_wait_for*]
#   Stop template variable to set the number of seconds to wait for JAVA stop.
# [*package_list*]
#   An array of AEM packages, service packs, and hotfixes filenames
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
  #   package_list            =>['AEM_6.0_Service_Pack_2-1.0.zip',
  #                               'http://myserver.com/cq-6.0-featurepack-4137-1.0.zip']
  # }

### TODO: Need to determine if there is a better way to do global variables
###       then using hiera().  Need to validate after upgrade to PE 3.8
define adobe_em6::instance (
  $aem_bundle_status_user     = hiera('adobe_em6::instance::aem_bundle_status_user', 'admin'),
  $aem_bundle_status_passwd   = hiera('adobe_em6::instance::aem_bundle_status_passwd', 'admin'),
  $instance_type              = hiera('adobe_em6::instance::instance_type', 'UNSET'),
  $instance_port              = hiera('adobe_em6::instance::instance_port', 'UNSET'),
  $should_manage_compaction   = hiera('adobe_em6::instance::should_manage_compaction', 'false'),
  $provision_compact_tool     = hiera('adobe_em6::instance::provision_compact_tool', 'false'),
  $compact_disk_percent       = hiera('adobe_em6::instance::compact_disk_percent', '80'),
  $osgi_config_list           = hiera_hash('adobe_em6::instance::osgi_config_list', {} ),
  $replication_queues         = hiera_hash('adobe_em6::instance::replication_queues', {} ),
  $service_enable             = hiera('adobe_em6::instance::service_enable', 'true'),
  $service_ensure             = hiera('adobe_em6::instance::service_ensure', 'UNSET'),
  $start_classpath            = hiera('adobe_em6::instance::start_classpath', '/usr/java/latest/lib/tools.jar'),
  $start_file_size_limit      = hiera('adobe_em6::instance::start_file_size_limit', '8192'),
  $start_host                 = hiera('adobe_em6::instance::start_host', ''),
  $start_jaas_config          = hiera('adobe_em6::instance::start_jaas_config', 'etc/jaas.conf'),
  $start_jvm_aem_args         = hiera('adobe_em6::instance::start_jvm_aem_args', ''),
  $start_jvm_keystore_args    = hiera('adobe_em6::instance::start_jvm_keystore_args', ''),
  $start_jvm_memory_args      = hiera('adobe_em6::instance::start_jvm_memory_args', '-Xmx1024m -XX:MaxPermSize=256M'),
  $start_jvm_monitor_args     = hiera('adobe_em6::instance::start_jvm_monitor_args', ''),
  $start_jvm_property_args    = hiera('adobe_em6::instance::start_jvm_property_args', ''),
  $start_more_modes           = hiera('adobe_em6::instance::start_more_modes', 'dev'),
  $start_use_jaas             = hiera('adobe_em6::instance::start_use_jaas', ''),
  $stop_wait_for              = hiera('adobe_em6::instance::stop_wait_for', '120'),
  $package_list               = hiera_array('adobe_em6::instance::package_list',['UNSET']),
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
      fail('Not using default titles of publish or author, so need to set the
        instance_type and instance_port')
    }
  }
  else { # both parameters were passes in
    if !($instance_type in ['author', 'publish']) {
      fail("'${instance_type}' is not a valid 'instance_type' property.
        Should be 'author' or 'publish'.")
    }

    if $instance_port !~ /^\d{3,5}$/ {
      fail("'${instance_port}' is not a valid 'instance_port' property.
        Should be a number.")
    }

    $my_type  = $instance_type
    $my_port  = $instance_port
  }

  $dir_instance_location = "${adobe_em6::params::dir_aem_install}/${title}"

  ##################################
  ###  Instance's directory creation
  File {
    owner   => $adobe_em6::params::aem_user,
    group   => $adobe_em6::params::aem_group,
    mode    => '0755',
  }

  file { $dir_instance_location:
    ensure  => 'directory',
    require => File[$adobe_em6::params::dir_aem_install],
  }

  file { "${adobe_em6::params::dir_aem_log}/${title}":
    ensure  => 'directory',
    require => File[$adobe_em6::params::dir_aem_log],
  }

  ##################################
  ### Downloading and Jar Unpacking

  $dir_instance_crx_quickstart = "${dir_instance_location}/crx-quickstart"
  $aem_absolute_jar            = "${dir_instance_location}/${adobe_em6::params::pkg_aem_jar_name}"
  $exec_path                   = ['/bin', '/usr/bin', '/usr/local/bin', '/usr/java/latest/bin/' ]

  exec { "Download AEM jar for ${title}":
    command   => "wget -q -N -P ${dir_instance_location} ${adobe_em6::params::remote_url_for_files}/${adobe_em6::params::pkg_aem_jar_name}",
    cwd       => $dir_instance_location,
    logoutput => true,
    unless    => ["test -d ${dir_instance_crx_quickstart}"],
    path      =>  $exec_path,
    require   =>[Package['wget'], File[$dir_instance_location]],
    timeout   => $adobe_em6::params::exec_download_timeout,
    user      => $adobe_em6::params::aem_user,
  }

  exec { "Unpack AEM jar for ${title}":
    command   => "/usr/bin/java -jar ${aem_absolute_jar} -unpack; sleep 5",
    cwd       => $dir_instance_location,
    creates   => $dir_instance_crx_quickstart,
    logoutput => false,
    path      =>  $exec_path,
    require   =>[Exec["Download AEM jar for ${title}"], Package['java']],
    user      => $adobe_em6::params::aem_user,
  }

  exec { "Remove AEM jar after expansion":
    command     => "rm -f ${adobe_em6::params::pkg_aem_jar_name}",
    cwd         => $dir_instance_location,
    logoutput   => false,
    subscribe   => Exec["Unpack AEM jar for ${title}"],
    refreshonly => true,
    path        => $exec_path
  }

  ##################################
  ### Customizing AEM files

  file { "${dir_instance_location}/license.properties":
    ensure    => 'present',
    content   => template('adobe_em6/license.properties.erb'),
    subscribe  => Exec["Unpack AEM jar for ${title}"]
  }

  file { "${dir_instance_crx_quickstart}/bin/start":
    ensure    => 'present',
    content   => template('adobe_em6/start.erb'),
    subscribe => Exec["Unpack AEM jar for ${title}"]
  }

  file { "${dir_instance_crx_quickstart}/bin/stop":
    ensure    => 'present',
    content   => template('adobe_em6/stop.erb'),
    subscribe => Exec["Unpack AEM jar for ${title}"]
  }

  file { "${dir_instance_crx_quickstart}/logs":
    ensure    => 'link',
    target    => "${adobe_em6::params::dir_aem_log}/${title}",
    replace   => true,
    force     => true,
    subscribe => Exec["Unpack AEM jar for ${title}"]
  }

  # TODO:  Move this to be more dynamic  and allow user to set variables for this props files
  #        Ideas include create a define type that uses a define type or just variablize stuff.
  file { "${dir_instance_crx_quickstart}/conf/sling.properties":
    ensure  => 'present',
    content => template('adobe_em6/sling.properties.erb'),
    subscribe => Exec["Unpack AEM jar for ${title}"],
  }

  # TODO: Files to add:
  # config/* & sling.properties
  # What about custom configurations

  ##################################
  ### Creating AEM service
  adobe_em6::instance::service { "${title}_service_creation":
    service_enable  => $service_enable,
    service_ensure  => $service_ensure,
  }

  ##################################
  ### Applying Packages
  ## Creating install directory and downloading packages.
  file { "${dir_instance_crx_quickstart}/install":
    ensure  => 'directory',
    require => Exec["Unpack AEM jar for ${title}"]
  }

  $compact_jar = "${adobe_em6::params::dir_tools}/offlineCompact.jar"

  if ($should_manage_compaction == "true" or $provision_compact_tool == "true") {
    $compact_tool_present = 'present'
  }
  else {
    $compact_tool_present = 'absent'
  }

  file { $compact_jar:
    ensure => $compact_tool_present,
    require => Exec["Download compaction tool"]
  }

  exec { "Download compaction tool":
    command     => "wget -O offlineCompact.jar ${adobe_em6::params::remote_url_for_files}/${adobe_em6::params::compact_jar_name}",
    cwd         => "${adobe_em6::params::dir_tools}",
    creates     => $compact_jar,
    onlyif      => "test ${compact_tool_present} == 'present'",
    logoutput   => false,
    path        =>  $exec_path,
    require     =>[Package['wget']],
    timeout     => $adobe_em6::params::exec_download_timeout,
    user        => $adobe_em6::params::aem_user
  }
  
  file { "${adobe_em6::params::dir_tools}/aemUtils.sh":
    ensure => present,
    content => template('adobe_em6/aemUtils.erb')
  }

  ## TODO: This can be converted to an iteration feature starting in Puppet 3.2
  ##        for now making the array a hash and using a create_resource to call
  ##        the define type apply_packages
  if ($package_list !=['UNSET']) {

    validate_array($package_list)
    $aem_packages_hash = generate_resource_hash($package_list, 'filename', "${title}_package")
    $apply_packages_defaults = {
      'aem_bundle_status_user' => $aem_bundle_status_user,
      'aem_bundle_status_passwd' => $aem_bundle_status_passwd,
      'instance_type' => $my_type,
      'require' =>[File["${dir_instance_crx_quickstart}/install"], Service["set up service for ${title}"]]
    }

    create_resources('adobe_em6::instance::apply_packages', $aem_packages_hash, $apply_packages_defaults)
  }

  ### Creating replications queues for instances
  if !empty($replication_queues) {
    validate_hash($replication_queues)

    $replication_queues_defaults = {
      'instance_name' => $title,
      'instance_type' => $my_type,
      'aem_bundle_status_user' => $aem_bundle_status_user,
      'aem_bundle_status_passwd' => $aem_bundle_status_passwd,
      'require' =>[File["${dir_instance_crx_quickstart}/install"], Service["set up service for ${title}"]]
    }

    create_resources('adobe_em6::instance::replication_queues', $replication_queues, $replication_queues_defaults)
  }

  ### Creating replications queues for instances
  if !empty($osgi_config_list) {
    validate_hash($osgi_config_list)

    $osgi_config_defaults = {
      'aem_bundle_status_user' => $aem_bundle_status_user,
      'aem_bundle_status_passwd' => $aem_bundle_status_passwd,
      'instance_name' => $title,
      'require' =>[File["${dir_instance_crx_quickstart}/install"], Service["set up service for ${title}"]]
    }

    create_resources('adobe_em6::instance::apply_osgi_config', $osgi_config_list, $osgi_config_defaults)
  }

}
