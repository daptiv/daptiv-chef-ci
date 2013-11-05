require 'daptiv-chef-ci/virtualbox_basebox_builder'
require 'daptiv-chef-ci/logger'

describe DaptivChefCI::VirtualBoxBaseBoxBuilder, :integration => true do

  #Note- This test requires you have
  # 1. the dotnetframework cookbook cloned to ~/src/dotnetframework
  # 2. From ~/src/dotnetframework previously ran: vagrant up
  # 3. vagrant halt

  describe 'build' do
    it 'should build a VBox Vagrant base box' do
      base_dir = "#{ENV['HOME']}/src/dotnetframework"
      builder = DaptivChefCI::VirtualBoxBaseBoxBuilder.new(base_dir, DaptivChefCI::Shell.new())
      builder.build('dotnettest-vbox.box')
      expect(File.exists?("#{base_dir}/dotnettest-vbox.box"))
    end
  end
  
end
