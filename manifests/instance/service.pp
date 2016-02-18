# == Define: adobe_em::instance::service
#
# This module should be called from the instance define type in order
# to correct set up services when using a hash.
#
# === Parameters:
#
# [*service_enable*]
#   Either true or false to enable the AEM service
# [*service_ensure*]
#   Either stopped or running to control the running state of the service.
#   Disable(UNSET) by default#
#
# === External Parameters
#
# [*adobe_em6::params::dir_aem_install*]
#   base location here each AEM will be installed
#
# === Examples:
#

define adobe_em6::instance::service (
  $service_enable   = 'true',
  $service_ensure   = 'UNSET',
){

  ### Checks and other logic to set variables
  if !($service_enable in ['true', 'false', 'manual']) {
    fail("'${service_enable}' is not a valid 'enable' property.
     Should be 'true', 'false' or 'manual'.")
  }

  # In order to point to the correct start/stop files we need to split
  # the title which contains the instance name
  if size(split($title, '_')) >= 2 {
    $splitvals        = split($title, '_')
    $instance_name    = $splitvals[0]
  }
  else {
    fail("'${$title}' needs to contain the 'instance_name' following by '_'")
  }

  ### Creating AEM init.d files
  file { "/etc/init.d/aem_${instance_name}":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0744',
    content => template('adobe_em6/aem_type.erb'),
  }

  ### Setting up service
  if ($service_ensure == 'UNSET') {
    service { "set up service for ${instance_name}" :
      enable  => $service_enable,
      name    => "aem_${instance_name}",
      require => File["/etc/init.d/aem_${instance_name}"],
    }
  }
  elsif ($service_ensure in ['running', 'true', 'stopped', 'false']) {
    service { "set up service for ${instance_name}" :
      ensure      => $service_ensure,
      enable      => $service_enable,
      hasrestart  => true,
      hasstatus   => true,
      name        => "aem_${instance_name}",
      require     => [File["/etc/init.d/aem_${instance_name}"],
        File["${adobe_em6::params::dir_aem_install}/${instance_name}/crx-quickstart/bin/start"],
        File["${adobe_em6::params::dir_aem_install}/${instance_name}/license.properties"]
      ]
    }
  }
  else {
    fail("'${service_ensure}' is not a valid 'ensure' property. Should be
      'running', 'true', 'stopped' or 'false'.")
  }

}