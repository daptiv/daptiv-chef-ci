require 'rake'
require 'rake/tasklib'
require 'rake/dsl_definition'
require_relative 'vagrant_driver'
require_relative 'raketask_helper'
require_relative 'logger'

class VagrantProvision
  
  # Example usage, provisions a vmware box (box must already be up):
  #
  # VagrantProvision::RakeTask.new 'provision' do |t|
  #   t.provision_timeout_in_seconds = 3600
  #   t.environment = { :ENV_VAR1 => 'val1', :ENV_VAR2 => 'val2' }
  # end
  #
  # This class lets you define Rake tasks to drive Vagrant.
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined? ::Rake::DSL
    include DaptivChefCI::RakeTaskHelpers
    
    attr_accessor :vagrant_driver
    attr_accessor :provision_timeout_in_seconds
    attr_accessor :environment
    
    # @param [String] name The task name.
    # @param [String] desc Description of the task.
    # @param [String] provider vagrant provider to use if other than the default virtualbox provider
    def initialize(name = 'vagrant_provision', desc = 'Vagrant provision task')
      @name, @desc = name, desc
      @provision_timeout_in_seconds = 7200
      @environment = {}
      yield self if block_given?
      define_task
    end
    
    private

    def define_task
      desc @desc
      task @name do
        execute {
          vagrant_driver.provision({
            :cmd_timeout_in_seconds => @provision_timeout_in_seconds,
            :environment => @environment
          })
        }
      end
    end

    def vagrant_driver()
      @vagrant_driver ||= DaptivChefCI::VagrantDriver.new()
    end

  end
end

