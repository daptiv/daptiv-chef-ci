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
  #   t.environment = { :ENV_VAR1 => 'val1', :ENV_VAR2 => 'val2' }
  # end
  #
  # This class lets you define Rake tasks to drive Vagrant.
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined? ::Rake::DSL
    include DaptivChefCI::RakeTaskHelpers
    
    attr_accessor :vagrant_driver
    attr_accessor :provider
    attr_accessor :create_box
    attr_accessor :vagrantfile_dir
    attr_accessor :box_name
    attr_accessor :up_timeout_in_seconds
    attr_accessor :halt_timeout_in_seconds
    attr_accessor :destroy_timeout_in_seconds
    attr_accessor :destroy_retry_attempts
    attr_accessor :halt_retry_attempts
    attr_accessor :environment
    
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
      @environment = {}
      yield self if block_given?
      define_task
    end
    
    private

    def define_task
      desc @desc
      task @name do
        execute_vagrant_run()
      end
    end
    
    def execute_vagrant_run()
      execute { destroy() }
      try_vagrant_up()
    end
    
    def try_vagrant_up()
      begin
        execute do
          up()
          halt()
          package() if @create_box
        end
      ensure
        halt()
        destroy()
      end
    end
    
    def up()
      vagrant_driver.up({
        :cmd_timeout_in_seconds => @up_timeout_in_seconds,
        :environment => @environment
      })
    end
    
    def package()
      vagrant_driver.package({
        :base_dir => @vagrantfile_dir,
        :box_name => @box_name,
        :environment => @environment })
    end
    
    def destroy()
      vagrant_driver.destroy({
        :cmd_timeout_in_seconds => @destroy_timeout_in_seconds,
        :retry_attempts => @destroy_retry_attempts,
        :environment => @environment })
    end
    
    def halt()
      vagrant_driver.halt({
        :cmd_timeout_in_seconds => @halt_timeout_in_seconds,
        :retry_attempts => @halt_retry_attempts,
        :environment => @environment })
    end
    
    def vagrant_driver()
      @vagrant_driver ||= DaptivChefCI::VagrantDriver.new(@provider)
    end
    
  end
end

