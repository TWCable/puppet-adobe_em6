module Puppet::Parser::Functions
  newfunction(:create_configuration_package, :doc => <<-'ENDHEREDOC') do |args|
    Takes a FQDN/IP and convert them to Adobe (OSGi) configuration
    and creates a package to be used by the crx-quickstart/install directory
    to load those configurations

    For example:


    ENDHEREDOC



  end

end