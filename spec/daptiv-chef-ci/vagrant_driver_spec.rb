require 'mocha/api'
require 'daptiv-chef-ci/vagrant_driver'
require 'daptiv-chef-ci/logger'

describe DaptivChefCI::VagrantDriver, :unit => true do
  
  before(:each) do
    @shell = mock()
    @options = {}
    @vagrant = DaptivChefCI::VagrantDriver.new(@shell, @options)
  end

  describe 'render_vagrantfile' do
    it 'should default chef-repo dir to ~/src/chef-repo' do
      vagrantfile = @vagrant.render_vagrantfile()
      expect(vagrantfile).to include("chef_repo_dir = '#{ENV['HOME']}/src/chef-repo'")
    end
    
    it 'should not include box url when not set' do
      vagrantfile = @vagrant.render_vagrantfile()
      expect(vagrantfile).not_to include("config.vm.box_url")
    end
    
    it 'should include box url when set' do
      @options[:box_url] = 'http://example.com/boxes/freebsd.box'
      vagrantfile = @vagrant.render_vagrantfile()
      expect(vagrantfile).to include("config.vm.box_url = 'http://example.com/boxes/freebsd.box'")
    end

    it 'should include windows section when guest is set to windows' do
      @options[:guest_os] = :windows
      vagrantfile = @vagrant.render_vagrantfile()
      expect(vagrantfile).to include('config.vm.guest = :windows')
      expect(vagrantfile).to include('config.windows.halt_timeout = 15')
      expect(vagrantfile).to include('config.winrm.username = "vagrant"')
      expect(vagrantfile).to include('config.winrm.password = "vagrant"')
      expect(vagrantfile).to include('config.vm.network :forwarded_port, guest: 5985, host: 5985')
    end
    
    it 'should expand runlist' do
      @options[:run_list] = ['python', 'nginx']
      vagrantfile = @vagrant.render_vagrantfile()
      expect(vagrantfile).to include("chef.add_recipe 'python'")
      expect(vagrantfile).to include("chef.add_recipe 'nginx'")
    end
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
  end
  
  describe 'up' do
    it 'should up vagrant' do
      @shell.expects(:exec_cmd).with do |cmd|
        expect(cmd).to eq('vagrant up')
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
