require 'daptiv-chef-ci/vagrant_provision_task'
require_relative '../shared_contexts/rake'

describe VagrantProvision::RakeTask, :unit => true do
  include_context 'rake'

  describe 'vagrant_provision' do
    it 'should provision the box' do

      vagrant_driver.should_receive(:provision).with({ :cmd_timeout_in_seconds => 7200 })
      
      task = rake['vagrant_provision']
      task.invoke()

    end
  end
  
end
