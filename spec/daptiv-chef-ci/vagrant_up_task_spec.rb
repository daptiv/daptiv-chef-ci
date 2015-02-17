require 'daptiv-chef-ci/vagrant_up_task'
require_relative '../shared_contexts/rake'

describe VagrantUp::RakeTask, unit: true do
  include_context 'rake'

  describe 'vagrant_up' do
    it 'should up the box' do
      vagrant_driver.should_receive(:up)
        .with(cmd_timeout_in_seconds: 7200, environment: {})

      task = rake['vagrant_up']
      task.invoke
    end

    it 'should up the box with the specified environment vars' do
      environment = { ENV_VAR1: 'val1', ENV_VAR2: 'val2' }
      vagrant_driver.should_receive(:up)
        .with(cmd_timeout_in_seconds: 7200, environment: environment)

      task = rake['vagrant_up']
      subject.environment = environment
      task.invoke
    end
  end
end
