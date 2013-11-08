require 'rake'
require 'rake/tasklib'
require 'rake/dsl_definition'
require_relative 'vagrant_driver'
require_relative 'raketask_helper'
require_relative 'logger'

class Vagrant
  
  # Example usage, creates a vmware base box:
  #
  # Vagrant::RakeTask.new 'vagrant_fusion' do |t|
  #   t.provider = :vmware_fusion
  #   t.create_box = true
  #   t.box_name = 'windows-server-vmwarefusion.box'
  #   t.up_timeout_in_seconds = 3600
  # end
  #
  # This class lets you define Rake tasks to drive Vagrant.
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined? ::Rake::DSL
    include DaptivChefCI::RakeTaskHelpers
    
    attr_accessor :provider
    attr_accessor :create_box
    attr_accessor :vagrantfile_dir
    attr_accessor :box_name
    attr_accessor :up_timeout_in_seconds
    attr_accessor :halt_timeout_in_seconds
    attr_accessor :destroy_timeout_in_seconds
    attr_accessor :destroy_retry_attempts
    attr_accessor :halt_retry_attempts
    
    # @param [String] name The task name.
    # @param [String] desc Description of the task.
    # @param [String] provider vagrant provider to use if other than the default virtualbox provider
    def initialize(name = 'vagrant', desc = 'Vagrant up, halt, destroy, package task')
      @name, @desc = name, desc
      @provider = :virtualbox
      @create_box = false
      @vagrantfile_dir = Dir.pwd
      @box_name = nil
      @up_timeout_in_seconds = 7200
      @halt_timeout_in_seconds = 180
      @destroy_timeout_in_seconds = 180
      @destroy_retry_attempts = 2
      @halt_retry_attempts = 2
      yield self if block_given?
      define_task
    end
    
    private

    def define_task
      desc @desc
      task @name do
        vagrant = DaptivChefCI::VagrantDriver.new(@provider)
        execute_vagrant_run(vagrant)
      end
    end
    
    def execute_vagrant_run(vagrant)
      execute { destroy(vagrant) }
      try_vagrant_up(vagrant)
    end
    
    def try_vagrant_up(vagrant)
      begin
        execute do
          up(vagrant)
          halt(vagrant)
          package(vagrant) if @create_box
        end
      ensure
        halt(vagrant)
        destroy(vagrant)
      end
    end
    
    def up(vagrant)
      vagrant.up({ :cmd_timeout_in_seconds => @up_timeout_in_seconds })
    end
    
    def package(vagrant)
      vagrant.package({ :base_dir => @vagrantfile_dir, :box_name => @box_name })
    end
    
    def destroy(vagrant)
      vagrant.destroy({ :cmd_timeout_in_seconds => @destroy_timeout_in_seconds, :retry_attempts => @destroy_retry_attempts })
    end
    
    def halt(vagrant)
      vagrant.halt({ :cmd_timeout_in_seconds => @halt_timeout_in_seconds, :retry_attempts => @halt_retry_attempts })
    end
    
  end
end

