require 'mocha/api'
require 'mixlib/shellout/exceptions'
require 'daptiv-chef-ci/vagrant_driver'
require 'daptiv-chef-ci/logger'

describe DaptivChefCI::VagrantDriver, :unit => true do
  
  before(:each) do
    @shell = mock()
    @vagrant = DaptivChefCI::VagrantDriver.new(@shell)
  end

  describe 'destroy' do
    it 'should force shutdown vagrant' do
      @shell.expects(:exec_cmd).with do |cmd|
        expect(cmd).to eq('vagrant destroy -f')
      end
      @vagrant.destroy()
    end
  end
  
  describe 'halt' do
    it 'should halt vagrant' do
      @shell.expects(:exec_cmd).with do |cmd|
        expect(cmd).to eq('vagrant halt')
      end
      @vagrant.halt()
    end
    
    it 'should retry when exec fails' do
      # shell cmd fails then succeeds, the vagrant.halt should succeed overall
      @shell.stubs(:exec_cmd).raises(Mixlib::ShellOut::ShellCommandFailed, 'There was an error').then.returns('success')
      @vagrant.halt({ :retry_wait_in_seconds => 0 })
    end
    
    it 'should fail after retrying twice' do
      # shell always fails, vagrant.halt should fail after a couple retries
      @shell.stubs(:exec_cmd).raises(Mixlib::ShellOut::ShellCommandFailed, 'There was an error')
      expect { @vagrant.halt({ :retry_wait_in_seconds => 0 }) }.to raise_error(Mixlib::ShellOut::ShellCommandFailed)
    end
  end
  
  describe 'up' do
    it 'should up vagrant' do
      @shell.expects(:exec_cmd).with do |cmd|
        expect(cmd).to eq('vagrant up')
      end
      @vagrant.up()
    end
  end

  describe 'up with custom provider' do
    it 'should up vagrant' do
      @vagrant = DaptivChefCI::VagrantDriver.new(@shell, :my_custom_provider)
      @shell.expects(:exec_cmd).with do |cmd|
        expect(cmd).to eq('vagrant up --provider=my_custom_provider')
      end
      @vagrant.up()
    end
  end

  describe 'provision' do
    it 'should provision vagrant' do
      @shell.expects(:exec_cmd).with do |cmd|
        expect(cmd).to eq('vagrant provision')
      end
      @vagrant.provision()
    end
  end
  
  describe 'reload' do
    it 'should reload vagrant' do
      @shell.expects(:exec_cmd).with do |cmd|
        expect(cmd).to eq('vagrant reload')
      end
      @vagrant.reload()
    end
  end
  
end
