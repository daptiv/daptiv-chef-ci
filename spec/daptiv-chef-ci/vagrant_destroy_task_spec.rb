require 'daptiv-chef-ci/vagrant_destroy_task'
require_relative '../shared_contexts/rake'

describe VagrantDestroy::RakeTask, :unit => true do
  include_context 'rake'

  describe 'vagrant_destroy' do
    it 'should destroy the box' do

      vagrant_driver.should_receive(:destroy).with({ :cmd_timeout_in_seconds => 180, :environment => {} })
      
      task = rake['vagrant_destroy']
      task.invoke()

    end
  end
  
end
