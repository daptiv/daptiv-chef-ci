require 'daptiv-chef-ci/vagrant_task'
require_relative '../shared_contexts/rake'

describe Vagrant::RakeTask, unit: true do
  include_context 'rake'

  describe 'vagrant' do
    it 'should destroy, up, halt, then destroy the box' do
      vagrant_driver.should_receive(:destroy).with(
        cmd_timeout_in_seconds: 180,
        retry_attempts: 0,
        environment: {})
      vagrant_driver.should_receive(:up).with(
        cmd_timeout_in_seconds: 7200,
        environment: {})
      vagrant_driver.should_receive(:destroy).with(
        cmd_timeout_in_seconds: 180,
        retry_attempts: 2,
        environment: {})

      task = rake['vagrant']
      task.invoke
    end

    it 'should up the box with the specified environment vars' do
      environment = { ENV_VAR1: 'val1', ENV_VAR2: 'val2' }

      vagrant_driver.should_receive(:destroy).with(
        cmd_timeout_in_seconds: 180,
        retry_attempts: 0,
        environment: environment)
      vagrant_driver.should_receive(:up).with(
        cmd_timeout_in_seconds: 7200,
        environment: environment)
      vagrant_driver.should_receive(:destroy).with(
        cmd_timeout_in_seconds: 180,
        retry_attempts: 2,
        environment: environment)

      task = rake['vagrant']
      subject.environment = environment
      task.invoke
    end
  end
end
