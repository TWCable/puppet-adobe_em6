require 'spec_helper'

# The following class are tested in this spec file
#     adobe_em6
#

describe 'adobe_em6' do

  it { should contain_class('adobe_em6') }
  it { should contain_class('adobe_em6::pre_install') }

end