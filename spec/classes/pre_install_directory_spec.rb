require 'spec_helper'

# The following class are tested in this spec file
#     adobe_em6
#

shared_examples_for "adobe_em6::pre_install_directory generic tests" do

  # it { should contain_class('java').with(
  #    'version' => "#{java_version}"
  #   )
  # }

  it {
    should contain_file("#{dir_base}").with(
      'ensure'  => 'directory',
      'group'   => 'root',
      'mode'    => '0755',
      'owner'   => 'root',
      'path'    => "#{dir_base}",
    )
  }

  it {
    should contain_file("#{dir_base_apps}").with(
      'ensure'  => 'directory',
      'group'   => 'root',
      'mode'    => '0755',
      'owner'   => 'root',
      'path'    => "#{dir_base_apps}",
      'require' => "File[#{dir_base}]",
    )
  }

  it {
    should contain_file("#{dir_base_logs}").with(
      'ensure'  => 'directory',
      'group'   => 'root',
      'mode'    => '0755',
      'owner'   => 'root',
      'path'    => "#{dir_base_logs}",
      'require' => "File[#{dir_base}]",
    )
  }

  it {
    should contain_file("#{dir_base_tools}").with(
      'ensure'  => 'directory',
      'group'   => 'root',
      'mode'    => '0755',
      'owner'   => 'root',
      'path'    => "#{dir_base_tools}",
      'require' => "File[#{dir_base}]",
    )
  }

  it {
    should contain_file("#{dir_aem_certs}").with(
      'ensure'  => 'directory',
      'group'   => "#{aem_group}",
      'mode'    => '0755',
      'owner'   => "#{aem_user}",
      'path'    => "#{dir_aem_certs}",
    )
  }

  it {
    should contain_file("#{dir_aem_install}").with(
      'ensure'  => 'directory',
      'group'   => "#{aem_group}",
      'mode'    => '0755',
      'owner'   => "#{aem_user}",
      'path'    => "#{dir_aem_install}",
    )
  }

  it {
    should contain_file("#{dir_aem_log}").with(
      'ensure'  => 'directory',
      'group'   => "#{aem_group}",
      'mode'    => '0755',
      'owner'   => "#{aem_user}",
      'path'    => "#{dir_aem_log}",
    )
  }

  it {
    should contain_file("#{dir_tools}").with(
      'ensure'  => 'directory',
      'group'   => "#{aem_group}",
      'mode'    => '0755',
      'owner'   => "#{aem_user}",
      'path'    => "#{dir_tools}",
    )
  }

  it {
    should contain_file("#{dir_tools_log}").with(
      'ensure'  => 'directory',
      'group'   => "#{aem_group}",
      'mode'    => '0755',
      'owner'   => "#{aem_user}",
      'path'    => "#{dir_tools_log}",
    )
  }

end

describe 'adobe_em6::pre_install_directory' do

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
  let(:aem_group)             { 'aem' }
  let(:aem_user)              { 'aem' }
  let(:dir_base)              { '/data'}
  let(:dir_base_apps)         { '/data/apps'}
  let(:dir_base_logs)         { '/data/logs'}
  let(:dir_base_tools)        { '/data/tools'}
  let(:dir_aem_install)       { '/data/apps/aem' }
  let(:dir_aem_certs)         { '/data/apps/aem/certs' }
  let(:dir_aem_log)           { '/data/logs/aem' }
  let(:dir_tools)             { '/data/tools/aem' }
  let(:dir_tools_log)         { '/data/logs/tools' }
  let(:java_version)          { 'present' }

  #
  # Setting Global params defaults
  # let(:params) {{
  #   :java_version           => java_version,
  #   :dir_aem_install_base   => dir_aem_install_base,
  #   :dir_aem_log            => dir_aem_log_base,
  #   :dir_tools              => dir_tools_base,
  #   :dir_tools_log          => dir_tools_log,
  # }}

  it { should contain_class('adobe_em6') }
  it { should contain_class('adobe_em6::pre_install_directory') }

  context 'default configuration' do
    it_should_behave_like "adobe_em6::pre_install_directory generic tests"
  end

end