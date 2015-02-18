require 'mixlib/shellout/exceptions'
require 'daptiv-chef-ci/vagrant_driver'
require 'daptiv-chef-ci/logger'

describe DaptivChefCI::VagrantDriver, unit: true do
  before(:each) do
    @shell = mock
    @vagrant = DaptivChefCI::VagrantDriver.new(:virtualbox, @shell)
  end

  describe 'destroy' do
    it 'should force shutdown vagrant with a timeout of 180 seconds' do
      @shell.should_receive(:exec_cmd).with('vagrant destroy -f', 180, {})
      @vagrant.destroy
    end
  end

  describe 'halt' do
    it 'should halt vagrant with a timeout of 180 seconds' do
      @shell.should_receive(:exec_cmd).with('vagrant halt', 180, {})
      @vagrant.halt
    end

    it 'should retry when exec fails' do
      @shell.should_receive(:exec_cmd)
        .and_raise(Mixlib::ShellOut::ShellCommandFailed)
      @shell.should_receive(:exec_cmd).and_return('success')
      # shell cmd fails then succeeds, the vagrant.halt should succeed overall
      @vagrant.halt(retry_wait_in_seconds: 0)
    end

    it 'should fail after retrying twice' do
      # shell always fails, vagrant.halt should fail after a couple retries
      @shell.should_receive(:exec_cmd)
        .exactly(3).times.and_raise(Mixlib::ShellOut::ShellCommandFailed)
      expect { @vagrant.halt(retry_wait_in_seconds: 0) }
        .to raise_error(Mixlib::ShellOut::ShellCommandFailed)
    end
  end

  describe 'up' do
    it 'should up vagrant with a timeout of 7200 seconds' do
      @shell.should_receive(:exec_cmd).with(
        'vagrant up --provider=virtualbox', 7200, {})
      @vagrant.up
    end

    it 'should up vagrant and specify the provider if not virtualbox' do
      @vagrant = DaptivChefCI::VagrantDriver.new(:my_custom_provider, @shell)
      @shell.should_receive(:exec_cmd).with(
        'vagrant up --provider=my_custom_provider', 7200, {})
      @vagrant.up
    end

    it 'should pass along environment variables' do
      environment = { A: 'A' }
      @shell.should_receive(:exec_cmd)
        .with('vagrant up --provider=virtualbox', 7200, environment)
      @vagrant.up(environment: environment)
    end
  end

  describe 'provision' do
    it 'should provision vagrant with a timeout of 7200 seconds' do
      @shell.should_receive(:exec_cmd).with('vagrant provision', 7200, {})
      @vagrant.provision
    end

    it 'should pass along environment variables' do
      environment = { A: 'A' }
      @shell.should_receive(:exec_cmd)
        .with('vagrant provision', 7200, environment)
      @vagrant.provision(environment: environment)
    end
  end
end
