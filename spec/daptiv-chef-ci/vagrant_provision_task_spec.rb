require 'daptiv-chef-ci/vagrant_provision_task'
require_relative '../shared_contexts/rake'

describe VagrantProvision::RakeTask, unit: true do
  include_context 'rake'

  describe 'vagrant_provision' do
    it 'should provision the box' do
      vagrant_driver.should_receive(:provision)
        .with(cmd_timeout_in_seconds: 7200, environment: {})
      task = rake['vagrant_provision']
      task.invoke
    end

    it 'should up the box with the specified environment vars' do
      environment = { ENV_VAR1: 'val1', ENV_VAR2: 'val2' }
      vagrant_driver.should_receive(:provision)
        .with(cmd_timeout_in_seconds: 7200, environment: environment)

      task = rake['vagrant_provision']
      subject.environment = environment
      task.invoke
    end
  end
end
