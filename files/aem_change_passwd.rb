#!/usr/bin/env ruby
#
# This script validates, updates, and checks for default admin credentials for AEM.
# Example usage:
#   Update admin password:
#       ./aem_change_passwd.rb --verbose --console-user=admin --console-pass=admin --newpass=test
#   Check if an instance is using default admin credentials:
#       ./aem_change_passwd.rb --default-credentials
#   Test user credentials against an instance:
#       ./aem_change_passwd.rb --authentication-check --console-user=admin --console-pass=admin
#
require 'rubygems'
require 'json'
require 'uri'
require 'net/http'

class AemChangePasswd
    attr_accessor :verbose
    def self.check_authentication(console_user, console_pass, console_host, console_port)
        url = URI("http://#{console_host}:#{console_port}/crx/de/j_security_check")
        response = Net::HTTP::post_form(url, 'j_username' => console_user, 'j_password' => console_pass, 'j_workspace' => 'crx.default', 'j_validate' => true, '_charset_' => 'utf-8')

        case response
        when Net::HTTPSuccess, Net::HTTPRedirection
            puts "Authenticated to #{url.to_s} successfully."
            return true
        else
            puts "Problem authenticating to #{url.to_s}: #{response}"
            return false
        end
    end

    def self.default_credentials?(console_host, console_port)
        return check_authentication('admin', 'admin', console_host, console_port)
    end

    def self.get_user_properties(console_user, console_pass, console_host, console_port, userch='admin')
        query = "path=/home/users&1_property=rep:authorizableId&1_property.value=#{userch}&p.limit=-1"
        url = URI("http://#{console_host}:#{console_port}/bin/querybuilder.json?#{query}")

        request = Net::HTTP::Get.new(url.request_uri)
        request.basic_auth console_user, console_pass
        response = Net::HTTP.start(url.host, url.port) { |http|
            http.request(request)
        }

        case response
        when Net::HTTPSuccess, Net::HTTPRedirection
            return JSON.parse(response.body)
        else
            raise RuntimeError, "Obtaining #{userch} path not successful. Response: #{response}"
        end
    end

    def self.setpassword(user, pass, console_host, console_port, new_passwd, user_path)
        url = URI("http://" + console_host + ":" + console_port + "/crx/explorer/ui/setpassword.jsp")

        response = Net::HTTP.start(url.host, url.port) { |http|
            request = Net::HTTP::Post.new url.request_uri
            request.basic_auth user, pass
            request.set_form_data('plain' => new_passwd, 'verify' => new_passwd, 'old' => pass, 'Path' => user_path)
            http.request(request)
        }

        case response
        when Net::HTTPSuccess, Net::HTTPRedirection
            # OK
        else
            raise(Puppet::ParseError, user + " password change not successful, response is " + response)
        end
    end
end # AemChangePasswd

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

options = OpenStruct.new

# Defaults
# Connection info
options.console_host = 'localhost'
options.console_port = '4502'

# User used to access the console
options.console_user = 'admin'
options.console_pass = 'admin'

# User to change and it related passwords
options.userch = 'admin'
options.newpass = 'nimda'

# Diagnostic options
options.authcheck = false
options.default_creds = false

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

    opts.on("-c", "--console-user [console user]", "Console username. Default: #{options.console_user}") do |cuser|
        options.console_user = cuser
    end

    opts.on("-p", "--console-pass [console passwd]", "Console password. Default: #{options.console_pass}") do |cpass|
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

    opts.on("-g", "--get-user-properties", "Attempt to fetch and display user property information") do |get_user_properties|
        options.get_user_properties = get_user_properties
    end

    opts.on("-a", "--authentication-check", "Connect to AEM instance and attempt to verify if provided credentials are valid") do |authcheck|
        options.authcheck = authcheck
    end

    opts.on("-d", "--default-credentials", "Check instance for default authentication credentials") do |default_creds|
        options.default_creds = default_creds
    end
end

opt_parser.parse!(ARGV)

if options.verbose
    puts "Options:\n"
    options.to_h.sort.map { |k,v| puts "#{k}: #{v}" }
    puts "\n"
end

if options.authcheck
    exit(AemChangePasswd.check_authentication(options.console_user, options.console_pass, options.console_host, options.console_port))
end

if options.default_creds
    if(AemChangePasswd.default_credentials?(options.console_host, options.console_port))
        puts "WARNING: #{options.console_host}:#{options.console_port} uses default admin credentials!"
        exit(1)
    else
        puts "#{options.console_host}:#{options.console_port} is not using default admin credentials."
        exit
    end
end

if options.get_user_properties
    pp AemChangePasswd.get_user_properties(options.console_user, options.console_pass, options.console_host, options.console_port)
    exit
end

# Check if an update is required by determining if we can successfully authenticate using the new credentials
puts "Checking if password needs to be updated..." if options.verbose
if AemChangePasswd.check_authentication(options.console_user, options.newpass, options.console_host, options.console_port)
    puts "Password is up to date. Exiting successfully!" if options.verbose
    exit!
end

# Verify we can authenticate with old current user/pass
puts "Verifying ability to authenticate using current user/pass..." if options.verbose
if AemChangePasswd.check_authentication(options.console_user, options.console_pass, options.console_host, options.console_port)
    puts "Authenticated successfully. Updating credentials." if options.verbose
    user_properties = AemChangePasswd.get_user_properties(options.console_user, options.console_pass, options.console_host, options.console_port, options.userch)
    puts "user_properties is #{user_properties}" if options.verbose
    user_path = user_properties["hits"][0]["path"]
    puts "user_path: #{user_path}" if options.verbose

    # Update the password
    AemChangePasswd.setpassword(options.console_user, options.console_pass, options.console_host, options.console_port, options.newpass, user_path)

    # Verify that we can authenticate using the new credentials
    puts "Updated. Verifying new credentials..."
    if AemChangePasswd.check_authentication(options.console_user, options.newpass, options.console_host, options.console_port)
        puts "New credentials verified successfully!" if options.verbose
    end
else
    raise "Unable to authenticate with provided credentials: #{options.console_user}:#{options.console_pass}"
end
