require 'puppetlabs_spec_helper/module_spec_helper'
require 'puppet'
require 'rspec'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
module_path = File.expand_path(File.join(fixture_path, 'modules'))

RSpec.configure do |c|
  c.mock_with :rspec

  def clear_facts
    Facter.clear
    Facter.clear_messages
  end

  c.before(:each, :type => :fact) do
    # Need to make sure we clear out our facts at the start to make sure that
    # we don't pick up some facts left over from rspec-puppet
    clear_facts
  end
  c.after(:each, :type => :fact) do
    clear_facts
  end

  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  # we don't want to run tests from submodules in fixtures/sts/..
  c.pattern = "spec/*/*_spec.rb"

  # c.hiera_config = 'spec/fixtures/hiera.yaml'

  # c.before(:all) do
  #   data = YAML.load_file(c.hiera_config)
  #   data[:yaml][:datadir] = File.join(module_path, 'hieradata')
  #   File.open(c.hiera_config, 'w') do |f|
  #     f.write data.to_yaml
  #   end
  # end

end
