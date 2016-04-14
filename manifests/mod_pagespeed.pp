# Define: adobe_em::instance::mod_pagespeed
#
# Download and unpack the binaries for mod_pagespeed.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
define adobe_em::instance::package (
  $cms_type,
  $cms_port,
) {

  case $cms_type {
    'author',
    'publish' : {}
    default   : {
      fail("'${cms_type}' is not a valid 'cms_type' property. Should be 'author' or 'publish'.")
    }
  }

  case $cms_port {
    /^\d{3,5}$/ : {}
    default     : {
      fail("'${cms_port}' is not a valid 'cms_port' property. Should be a number.")
    }
  }

  require adobe_em

  #TODO:: DISPATCHER
  #if $adobe_em::package_aem_installation == true {
  #  notify { "INFO: Downloading ${cms_type} RPM": }
  #  ->
  #  package { "${adobe_em::package_aem_name}_${cms_type}":
  #    ensure => $adobe_em::package_aem_version,
  #    require => Package['jdk'],
  #  }
  #} else {

    notify { "INFO: sudo yum install -y at": }
    ->
    exec { "sudo yum install -y at":
      command => "sudo yum install -y at",
      timeout => 0
    }

    notify { "INFO: curl -O  https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_x86_64.rpm": }
    ->
    exec { "curl -O  https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_x86_64.rpm":
      command => "curl -O  https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_x86_64.rpm",
      timeout => 0
    }

    notify { "INFO: rpm mod-pagespeed": }
    ->
    exec { "rpm mod-pagespeed":
      command => "sudo rpm -U mod-pagespeed-*.rpm",
      timeout => 0
    }

    notify { "INFO: rpm mod-pagespeed": }
    ->
    exec { "rpm mod-pagespeed":
      command => "sudo rpm -U mod-pagespeed-*.rpm",
      timeout => 0
    }

    file { "make mod_pagespeed.so executable" :
      ensure  => 'file',
      path    => "/etc/httpd/modules/mod_pagespeed.so",
      owner   => $adobe_em::cms_user,
      group   => $adobe_em::cms_group,
      mode    => '0777'],
    }

    file { "make mod_pagespeed_ap24.so executable" :
      ensure  => 'file',
      path    => "/etc/httpd/modules/mod_pagespeed_ap24",
      owner   => $adobe_em::cms_user,
      group   => $adobe_em::cms_group,
      mode    => '0777'],
    }

    #TODO: ! need to copy up conf.d/pagespeed.conf as we want it - don't want to change things after the fact

    sudo apachectl -k graceful

    notify { "INFO: restart apache": }
    ->
    exec { "restart apache":
      command => "sudo apachectl -k graceful",
      timeout => 0
    }

  #TODO: DISPATCHER}

}