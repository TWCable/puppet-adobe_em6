require 'bundler'
#Bundler.require(:rake)  ## seems to case a load error
require 'rake/clean'

#require 'ci/reporter/rake/rspec'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rake'
require 'rspec/core/rake_task'
require 'rubygems'


#PuppetLint.configuration.ignore_paths = ["spec/fixtures/modules/apt/manifests/*.pp"]
PuppetLint.configuration.ignore_paths = ["spec/fixtures/modules/apt/manifests/*.pp"]
PuppetLint.configuration.log_format = '%{path}:%{linenumber}:%{KIND}: %{message}'
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_autoloader_layout')

task :default => [:spec, :lint]
