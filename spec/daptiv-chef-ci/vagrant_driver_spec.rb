require 'mixlib/shellout/exceptions'
require 'daptiv-chef-ci/vagrant_driver'
require 'daptiv-chef-ci/logger'

describe DaptivChefCI::VagrantDriver, :unit => true do
  
  before(:each) do
    @shell = mock()
    @basebox_builder_factory = stub()
    @vagrant = DaptivChefCI::VagrantDriver.new(@shell, @basebox_builder_factory)
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
      @vagrant = DaptivChefCI::VagrantDriver.new(@shell, @basebox_builder_factory, :my_custom_provider)
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
  
  describe 'package' do
    it 'should default to virtualbox and base_dir to current working dir' do
      builder = double('builder').as_null_object
      @basebox_builder_factory.expects(:create).with(@shell, :virtualbox, Dir.pwd).returns(builder)
      @vagrant.package()
    end
  end
  
  describe 'package' do
    it 'should use the specified provider' do
      builder = double('builder').as_null_object
      @vagrant = DaptivChefCI::VagrantDriver.new(@shell, @basebox_builder_factory, :vmware_fusion)
      @basebox_builder_factory.expects(:create).with(@shell, :vmware_fusion, Dir.pwd).returns(builder)
      @vagrant.package()
    end
  end
  
  describe 'package' do
    it 'should use the specified base_dir' do
      builder = double('builder').as_null_object
      @basebox_builder_factory.expects(:create).with(@shell, :virtualbox, '/Users/admin/mybox').returns(builder)
      @vagrant.package({ :base_dir => '/Users/admin/mybox' })
    end
  end
  
  describe 'package' do
    it 'should default box_name to directory name' do
      builder = mock('builder')
      builder.expects(:build).with('mybox.box')
      @basebox_builder_factory.stub(:create).and_return(builder)
      @vagrant.package({ :base_dir => '/Users/admin/mybox' })
    end
  end
  
  describe 'package' do
    it 'should ensure box name ends with .box' do
      builder = mock('builder')
      builder.expects(:build).with('mybox.box')
      @basebox_builder_factory.stub(:create).and_return(builder)
      @vagrant.package({ :box_name => 'mybox' })
    end
  end
  
end
