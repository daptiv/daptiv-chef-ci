require 'daptiv-chef-ci/vagrant_task'
require_relative '../shared_contexts/rake'

describe Vagrant::RakeTask, :unit => true do
  include_context 'rake'

  describe 'vagrant' do
    it 'should destroy, up, halt, then destroy the box' do
      
      vagrant_driver.should_receive(:destroy).with({ :cmd_timeout_in_seconds => 180, :retry_attempts => 2 })
      vagrant_driver.should_receive(:up).with({ :cmd_timeout_in_seconds => 7200 })
      vagrant_driver.should_receive(:halt).at_least(1).times.with({ :cmd_timeout_in_seconds => 180, :retry_attempts => 2 })
      vagrant_driver.should_receive(:destroy).with({ :cmd_timeout_in_seconds => 180, :retry_attempts => 2 })
      
      task = rake['vagrant']
      task.invoke()

    end
  end
  
end
