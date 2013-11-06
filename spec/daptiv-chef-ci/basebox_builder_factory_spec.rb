require 'daptiv-chef-ci/basebox_builder_factory'
require 'daptiv-chef-ci/virtualbox_basebox_builder'
require 'daptiv-chef-ci/vmware_basebox_builder'

describe DaptivChefCI::BaseBoxBuilderFactory, :unit => true do
  
  before(:each) do
    @shell = stub()
    @factory = DaptivChefCI::BaseBoxBuilderFactory.new()
  end

  describe 'create' do
    
    it 'should create VMware builder when provider is vmware_fusion' do
      builder = @factory.create(@shell, :vmware_fusion, Dir.pwd)
      expect(builder).to be_an_instance_of(DaptivChefCI::VMwareBaseBoxBuilder)
    end
    
    it 'should create VMware builder when provider is virtualbox' do
      builder = @factory.create(@shell, :virtualbox, Dir.pwd)
      expect(builder).to be_an_instance_of(DaptivChefCI::VirtualBoxBaseBoxBuilder)
    end
    
  end
end
