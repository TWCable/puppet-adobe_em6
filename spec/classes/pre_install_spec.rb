require 'spec_helper'

# The following class are tested in this spec file
#     adobe_em6
#

shared_examples_for "adobe_em6::pre_install generic tests" do

  # it { should contain_class('java').with(
  #   'version' => "#{java_version}"
  #   )
  # }

  it {
    should contain_file('create base cms base install dir').with(
      'ensure'  => 'present',
      'group'   => "#{cms_group}",
      'mode'    => '0755',
      'path'    => "#{dir_cms_install_base}",
      'owner'   => "#{cms_user}",
    )
  }

end

describe 'adobe_em6::pre_install' do

  let :pre_condition do
    'class { "adobe_em6": }'
  end

  ## The following setting are used to allow reuse of tests.
  # Just set the variables to a different setting in your context blocks
  #
  # Setting default Facts
  #let(:facts) { { :osfamily => 'RedHat' } }
  #
  # Setting variables to be used for params
  let(:cms_group)             { 'aem' }
  let(:cms_user)              { 'aem' }
  let(:dir_cms_install_base)  { '/data/apps/aem' }
  let(:dir_cms_log_base)      { '/data/logs/aem' }
  let(:dir_tools_base)        { '/data/tools/aem' }
  let(:dir_tools_log)         { '/data/logs/tools/aem' }
  let(:java_version)          { 'present' }

  #
  # Setting Global params defaults
  let(:params) {{
    :java_version           => java_version,
    :dir_cms_install_base   => dir_cms_install_base,
    :dir_cms_log_base       => dir_cms_log_base,
    :dir_tools_base         => dir_tools_base,
    :dir_tools_log          => dir_tools_log,
  }}

  it { should contain_class('adobe_em6') }
  it { should contain_class('adobe_em6::pre_install') }

  context 'default configuration' do
    it_should_behave_like "adobe_em6::pre_install generic tests"
  end

end