require 'daptiv-chef-ci/vmware_basebox_builder'
require 'daptiv-chef-ci/logger'

describe DaptivChefCI::VMwareBaseBoxBuilder, :integration => true do

  #Note- This test requires you have
  # 1. the dotnetframework cookbook cloned to ~/src/dotnetframework
  # 2. From ~/src/dotnetframework previously ran: vagrant up --provider vmware_fusion
  # 3. vagrant halt

  describe 'build' do
    it 'should build a VMware Vagrant base box' do
      base_dir = "#{ENV['HOME']}/src/dotnetframework"
      builder = DaptivChefCI::VMwareBaseBoxBuilder.new(base_dir)
      builder.build('dotnettest-vmware.box')
      expect(File.exists?("#{base_dir}/dotnettest-vmware.box"))
    end
  end
  
end
