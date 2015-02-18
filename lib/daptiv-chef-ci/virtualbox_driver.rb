require 'log4r'
require_relative 'shell'

module DaptivChefCI
  # Wrapper around VBox CLI for VM cleanup
  # Currently unused
  class VirtualBoxDriver
    def initialize(shell)
      @logger = Log4r::Logger.new('daptiv_chef_ci::virtual_box')
      @shell = shell
    end

    # Remove any running vms that have the same name as this box
    def cleanup_vms(box_name)
      list_all_running_vms.each do |vm|
        if vm.include?(box_name)
          machine_name = vm.split[0]
          @logger.debug("Found matching VBox #{machine_name} - Running")
          poweroff(machine_name)
          unregister(machine_name)
        else
          @logger.debug("Found no matching VBox #{machine_name}")
        end
      end
    end

    private

    # Power off the named virtual box
    def poweroff(machine_name)
      @logger.info("Powering off VM: #{machine_name}")
      @shell.exec_cmd("vboxmanage controlvm #{machine_name} poweroff")
    end

    # Unregister the virtual box. Must be powered off first.
    def unregister(machine_name)
      @logger.info("Unregistering VM: #{machine_name}")
      @shell.exec_cmd("vboxmanage unregistervm #{machine_name}")
    end

    # Get a list of running vms
    def list_all_running_vms
      @logger.info('List running VMs')
      @shell.exec_cmd('vboxmanage list runningvms') || ''
    end
  end
end
