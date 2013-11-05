require 'log4r'
require 'fileutils'
require_relative 'shell'

module DaptivChefCI
  
  # This class builds VMware Fusion 6 Vagrant boxes on OS X
  #
  # NOTE - This class makes a lot of assumptions that hopefully won't break until
  # after Vagrant natively supports packaging VMware Fusion boxes.
  class VMwareBaseBoxBuilder
    
    # Creates a new box builder instance
    #
    # @param [String] The full path to the directory where the Vagrantfile exists
    # of the box we want to package, i.e. /Users/admin/src/dotnetframework
    def initialize(base_dir)
      @base_dir = base_dir
      @logger = Log4r::Logger.new("daptiv_chef_ci::vmware_base_box_builder")
    end
    
    # Packages a VMware Fusion Vagrant box. This can take 15 minutes or so.
    #
    # @param [String] base box file name, i.e. 'windows-server-2008.box'
    def build(box_file)
      # /Users/admin/src/mybox/.vagrant/machines/default/vmware_fusion/0f721388-a327-4ba3-b203-c09f69016b43/
      box_root_path = "#{@base_dir}/.vagrant/machines/default/vmware_fusion"
      
      sub_dir = Dir["#{box_root_path}/*/"]
        .map { |d| File.basename(d) }
        .find { |d| d =~ /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/ }
        
      box_path = "#{box_root_path}/#{sub_dir}"
      @logger.debug("box_path: #{box_path}")
      
      build_box(box_path, box_file)
    end
    
    
    protected
    
    def build_box(box_path, box_file)
      tar_list_path = "#{box_path}/boxfilelist.txt"
      completed_box_path = "#{@base_dir}/#{box_file}"
      
      @logger.debug("tar_list_path: #{tar_list_path}")
      @logger.debug("completed_box_path: #{completed_box_path}")
      
      Dir.chdir(box_path) {
        vmdk_file = File.expand_path(Dir.glob("*.vmdk").first())
  
        args = [vdiskmanager_path]
        args << '-d'
        args << vmdk_file
        @logger.info("Defragging #{vmdk_file}")
        system(*args)
  
        args = [vdiskmanager_path]
        args << '-k'
        args << vmdk_file
        @logger.info("Shrinking #{vmdk_file}")
        system(*args)
        
        create_json_manifest(box_path)
        create_tar_manifest(tar_list_path)
        
        @logger.info("Packaging box #{box_file}")
        tar_cmd = "tar -czvf #{box_file} -T #{tar_list_path}"
        %x[#{tar_cmd}]
        FileUtils.rm(completed_box_path) if File.exists?(completed_box_path)
        FileUtils.mv(box_file, completed_box_path)
      }
 
      @logger.info("Done creating box #{completed_box_path}")
    end
    
    def create_tar_manifest(tar_list_path)
      @logger.debug("Creating manifest #{tar_list_path}")
      
      files = Dir.glob("*.{vmdk,nvram,plist,vmsd,vmx,vmxf,json}").join("\n")
      @logger.debug("Found the following files to pack: #{files}")
      
      FileUtils.rm(tar_list_path) if File.exists?(tar_list_path)
      IO.write(tar_list_path, files)
    end
    
    def create_json_manifest(box_path)
      json_manifest_path = File.join(box_path, "metadata.json")
      FileUtils.rm(json_manifest_path) if File.exists?(json_manifest_path)
      manifest = <<-EOH
{
    "provider":"vmware_fusion"
}
      EOH
      IO.write(json_manifest_path, manifest)
    end
    
    def vdiskmanager_path
      '/Applications/VMware Fusion.app/Contents/Library/vmware-vdiskmanager'
    end
    
  end
end