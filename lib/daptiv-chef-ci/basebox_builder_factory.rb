require 'log4r'
require_relative 'shell'
require_relative 'vmware_basebox_builder'
require_relative 'virtualbox_basebox_builder'

module DaptivChefCI
  
  # Abstract factory to produce base box builder instances based off the specified provider
  class BaseBoxBuilderFactory
    
    # Creates a new base box builder instance
    def create(shell, provider, base_dir)
      provider == :vmware_fusion ?
        DaptivChefCI::VMwareBaseBoxBuilder.new(base_dir) :
        DaptivChefCI::VirtualBoxBaseBoxBuilder.new(base_dir, shell)
    end
    
  end
end