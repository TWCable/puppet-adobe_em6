#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'uri'
require 'net/http'

class AemBundleStatus

	def self.get_bundles_status(bundles_uri, user, pass)
		uri = URI.parse(bundles_uri)
		req = Net::HTTP::Get.new(uri)
		req.basic_auth user, pass
		res = Net::HTTP.start(uri.hostname, uri.port) { |http|
	  		http.request(req)
		}

		JSON.parse(res.body)
	end
end # AemBundleStatus


require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

options = OpenStruct.new
options.console_uri  = 'http://localhost:4502/system/console/bundles.json'
options.console_user = 'admin'
options.console_pass = 'admin'

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

	opts.on("-a", "--address [uri]", "Address to pull bundles JSON info from. Default: #{options.console_uri}") do |address|
		options.console_uri = address
	end

	opts.on("-u", "--user [user]", "Console username. Default: #{options.console_user}") do |user|
		options.console_user = user
	end

	opts.on("-p", "--pass [pass]", "Console password. Default: #{options.console_pass}") do |pass|
		options.console_pass = pass
	end
end

opt_parser.parse!(ARGV)

bundles = AemBundleStatus.get_bundles_status(options.console_uri, options.console_user, options.console_pass)
p "Bundles status: #{bundles['status']}"
pp bundles if options.verbose

bundles['data'].each do |bundle|
	pp bundle if options.verbose
	if bundle['symbolicName'] == 'org.apache.sling.startupfilter.disabler'
		if bundle['state'] == 'Active'
			puts "Bundle '#{bundle['symbolicName']}' status is #{bundle['state']}. Returning successful exit code"
			exit(true)
		else
			puts "Bundle '#{bundle['symbolicName']}' status is #{bundle['state']}. Returning failure exit code."
			exit(false)
		end
	end
end

# We made it through all the bundles but didn't find startupfilter.disabler, so #failsauce
exit(false)
