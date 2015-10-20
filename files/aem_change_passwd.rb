#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'uri'
require 'net/http'

class AemChangePasswd

  def self.get_user_properties( console_user, console_pass, console_host, console_port, userch)

    query  = "path=/home/users&1_property=rep:authorizableId&1_property.value=#{userch}&p.limit=-1"
    url = URI("http://#{console_host}:#{console_port}/bin/querybuilder.json?#{query}")

    request = Net::HTTP::Get.new(url.request_uri)
    request.basic_auth console_user, console_pass
    response = Net::HTTP.start(url.host, url.port) { |http|
        http.request(request)
    }

    case response
    when Net::HTTPSuccess, Net::HTTPRedirection
        # OK
        JSON.parse(response.body)
    else
        p "Obtaining #{userch} path not successful, response is "
        raise(Puppet::ParseError, response)
        #"res.error!"
    end

  end

  def self.setpassword( user, pass, console_host, console_port, new_passwd, old_passwd, user_path )

    url = URI("http://" + console_host + ":" + console_port + "/crx/explorer/ui/setpassword.jsp")

    response = Net::HTTP.start(url.host, url.port) { |http|
      request = Net::HTTP::Post.new url.request_uri
      request.basic_auth user, pass
      request.set_form_data('plain' => new_passwd, 'verify' => new_passwd, 'old' => old_passwd, 'Path' => user_path)
      http.request(request)
    }

    case response
    when Net::HTTPSuccess, Net::HTTPRedirection
        # OK
    else
        raise(Puppet::ParseError, user + " password change not successful, response is " + response)
        #"res.error!"
    end

  end

end # AemChangePasswd

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

options = OpenStruct.new

# Connection info.
options.console_host = 'localhost'
options.console_port = '4502'

# User used to access the console
options.console_user = 'admin'
options.console_pass = 'admin'

# User to change and it related passwords
options.userch = 'admin'
options.oldpass   = 'admin'
options.newpass   = 'nimda'

opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"

  opts.separator ""
  opts.separator "Options:"

  opts.on("-h", "--help", "Print usage info") do |n|
    puts opts
    exit
  end

  opts.on("-v", "--verbose", "Print verbose output") do |v|
    options.verbose = v
  end

  opts.on("-c", "--cuser [console user]", "Console username. Default: #{options.console_user}") do |cuser|
    options.console_user = cuser
  end

  opts.on("-p", "--cpass [console passwd]", "Console password. Default: #{options.console_pass}") do |cpass|
    options.console_pass = cpass
  end

  opts.on("-s", "--host [hostname]", "Host to perform action on. Default: #{options.console_host}") do |host|
    options.console_host = host
  end

  opts.on("-t", "--port [port]", "Port to perform action on. Default: #{options.console_port}") do |port|
    options.console_port = port
  end

  opts.on("-u", "--userch [username]", "User name to change Default: #{options.user2ch}") do |userch|
    options.userch = userch
  end

  opts.on("-n", "--newpass [new password]", "User new Password Default: #{options.newpass}") do |newpass|
    options.newpass = newpass
  end

  opts.on("-o", "--oldpass [old password]", "Console password. Default: #{options.oldpass}") do |oldpass|
    options.oldpass = oldpass
  end
end

opt_parser.parse!(ARGV)

p "options.console_user is #{options.console_user}" if options.verbose
p "options.console_pass is #{options.console_pass}" if options.verbose
p "options.console_port is #{options.console_port}" if options.verbose
p "options.userch is #{options.userch}" if options.verbose
p "options.newpass is #{options.newpass}" if options.verbose
p "options.newpass is #{options.newpass}" if options.verbose

user_properties = AemChangePasswd.get_user_properties(options.console_user, options.console_pass, options.console_host, options.console_port, options.userch)
pp "user_properties is #{user_properties}" if options.verbose

user_path = user_properties["hits"][0]["path"]
p "user_path is #{user_path}" if options.verbose

AemChangePasswd.setpassword(options.console_user, options.console_pass, options.console_host, options.console_port, options.newpass, options.oldpass, user_path )
