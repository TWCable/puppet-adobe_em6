require 'bundler'
#Bundler.require(:rake)
require 'rake/clean'

require 'rake'
require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'
require 'puppet-lint/tasks/puppet-lint'

#PuppetLint.configuration.ignore_paths = ["spec/fixtures/modules/apt/manifests/*.pp"]
PuppetLint.configuration.ignore_paths = ["spec/fixtures/modules/apt/manifests/*.pp", "spec/fixtures/modules/apt/modules/*.pp"]
PuppetLint.configuration.log_format = '%{path}:%{linenumber}:%{KIND}: %{message}'
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_autoloader_layout')

task :default => [:spec, :lint]
