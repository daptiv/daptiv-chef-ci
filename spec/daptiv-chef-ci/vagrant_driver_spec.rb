require 'mocha/api'
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
