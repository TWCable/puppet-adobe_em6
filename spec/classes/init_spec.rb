require 'spec_helper'

# The following class are tested in this spec file
#     adobe_em6
#

describe 'adobe_em6' do

  #let(:remote_url_for_files)      { 'http://relic-01.cdp.webapps.rr.com/artifactory/files-local/adobe/aem/6.0' }

  it { should contain_class('adobe_em6') }
  it { should contain_class('adobe_em6::pre_install_directory') }

end