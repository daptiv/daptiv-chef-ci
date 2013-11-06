require 'log4r'
require 'fileutils'
require_relative 'shell'

module DaptivChefCI
  
  # This class builds VBox Vagrant boxes
  class VirtualBoxBaseBoxBuilder
    
    # Creates a new box builder instance
    #
    # @param [String] The full path to the directory where the Vagrantfile exists
    # of the box we want to package, i.e. /Users/admin/src/dotnetframework
    # @param [Shell] A shell instance
    def initialize(base_dir, shell)
      @shell = shell
      @base_dir = base_dir
      @logger = Log4r::Logger.new("daptiv_chef_ci::vmware_base_box_builder")
    end
    
    # Packages a VBox Vagrant box. This can take 15 minutes or so.
    #
    # @param [String] base box file name, i.e. 'windows-server-2008.box'
    def build(box_file)
      Dir.chdir(@base_dir) {
        @logger.info("Packaging box #{box_file}")
        FileUtils.rm(box_file) if File.exists?(box_file)
        @shell.exec_cmd("vagrant package --output #{box_file}", 1800)
      }
    end
    
  end
end