require 'spec_helper'

shared_examples_for "adobe_em6::instance tests" do

  let :title do
    "#{aem_type}"
  end


  it {
    should contain_file("#{dir_aem_install}/#{aem_type}").with(
      'ensure'  => 'directory',
      'group'   => "#{aem_group}",
      'mode'    => '0755',
      'owner'   => "#{aem_user}",
      'path'    => "#{dir_aem_install}/#{aem_type}",
    )
  }

  it {
    should contain_file("#{dir_aem_log}/#{aem_type}").with(
      'ensure'  => 'directory',
      'group'   => "#{aem_group}",
      'mode'    => '0755',
      'owner'   => "#{aem_user}",
      'path'    => "#{dir_aem_log}/#{aem_type}",
    )
  }

  it {
    should contain_package("#{aem_package}").with(
      'ensure'  => 'present',
    )
  }

end

describe 'adobe_em6::instance' do

  ## The following setting are used to allow reuse of tests.
  # Just set the variables to a different setting in your context blocks
  #
  # Setting default Facts
  #let(:facts) { { :osfamily => 'RedHat' } }
  #
  # Setting variables to be used for params
  let(:aem_group)             { 'aem' }
  let(:aem_user)              { 'aem' }
  let(:dir_aem_install)       { '/data/apps/aem' }
  let(:dir_aem_log)           { '/data/logs/aem' }
  #let(:adobe::params::remote_url_for_files)      { 'http://relic-01.cdp.webapps.rr.com/artifactory/files-local/adobe/aem/6.0' }

  context 'using title of author to set configuration' do
    let(:aem_port)       { '4502' }
    let(:aem_type)       { 'author' }
    let(:aem_package)    { 'aem6_author' }

    it_should_behave_like "adobe_em6::instance tests"

  end

  context 'using title of publish to set configuration' do
    let(:aem_port)       { '4503' }
    let(:aem_type)       { 'publish' }
    let(:aem_package)    { 'aem6_publish' }

    it_should_behave_like "adobe_em6::instance tests"

  end

  context 'using class params to set configuration for an author instance' do
    let(:aem_port)       { '4502' }
    let(:aem_type)       { 'author' }
    let(:aem_package)    { 'aem6_author' }

    let(:params) {{
      :aem_type         => "#{aem_type}",
      :aem_port         => "#{aem_port}",
      :package_name     => "#{aem_package}",
    }}

  end

  context 'using class params to set configuration for a publish instance' do
    let(:aem_port)       { '4503' }
    let(:aem_type)       { 'publish' }
    let(:aem_package)    { 'aem6_publish' }

    let(:params) {{
      :aem_type         => "#{aem_type}",
      :aem_port         => "#{aem_port}",
      :package_name     => "#{aem_package}",
    }}

    it_should_behave_like "adobe_em6::instance tests"

  end

end