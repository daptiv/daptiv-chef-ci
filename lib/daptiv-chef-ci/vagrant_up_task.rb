require 'rake'
require 'rake/tasklib'
require 'rake/dsl_definition'
require_relative 'vagrant_driver'
require_relative 'raketask_helper'
require_relative 'logger'

class VagrantUp
  
  # Example usage, ups and provisions a Vagrant box without halting or destroying it.
  #
  # VagrantUp::RakeTask.new 'up' do |t|
  #   t.provider = :vmware_fusion
  #   t.up_timeout_in_seconds = 3600
  #   t.environment = { :ENV_VAR1 => 'val1', :ENV_VAR2 => 'val2' }
  # end
  #
  # This class lets you define Rake tasks to drive Vagrant.
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined? ::Rake::DSL
    include DaptivChefCI::RakeTaskHelpers
    
    attr_accessor :vagrant_driver
    attr_accessor :provider
    attr_accessor :up_timeout_in_seconds
    attr_accessor :environment
    
    # @param [String] name The task name.
    # @param [String] desc Description of the task.
    # @param [String] provider vagrant provider to use if other than the default virtualbox provider
    def initialize(name = 'vagrant_up', desc = 'Vagrant up task')
      @name, @desc = name, desc
      @provider = :virtualbox
      @up_timeout_in_seconds = 7200
      @environment = {}
      @vagrant_driver = DaptivChefCI::VagrantDriver.new(@provider)
      yield self if block_given?
      define_task
    end
    
    private

    def define_task
      desc @desc
      task @name do
        execute {
          @vagrant_driver.up({
            :cmd_timeout_in_seconds => @up_timeout_in_seconds,
            :environment => @environment
          })
        }
      end
    end

  end
end

