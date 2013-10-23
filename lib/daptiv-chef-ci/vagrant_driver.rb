require 'log4r'
require_relative 'shell'

module DaptivChefCI
  class VagrantDriver
    
    # Constructs a new Vagrant management instance
    #
    # @param [Shell] The CLI
    def initialize(shell)
      @logger = Log4r::Logger.new("daptiv_chef_ci::vagrant")
      @shell = shell
    end
    
    def destroy()
      @shell.exec_cmd('vagrant destroy -f')
    end
    
    def halt()
      @shell.exec_cmd('vagrant halt')
    end
    
    def up()
      @shell.exec_cmd('vagrant up')
    end
    
    def provision()
      @shell.exec_cmd('vagrant provision')
    end
    
    def reload()
      @shell.exec_cmd('vagrant reload')
    end
    
  end
end