require 'rake'
require 'rake/tasklib'
require 'rake/dsl_definition'
require_relative 'vagrant_driver'
require_relative 'raketask_helper'
require_relative 'logger'

class VagrantDestroy
  
  # Example usage, destroys a Vagrant box.
  #
  # VagrantUp::RakeTask.new 'up' do |t|
  #   t.destroy_timeout_in_seconds = 180
  # end
  #
  # This class lets you define Rake tasks to drive Vagrant.
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined? ::Rake::DSL
    include DaptivChefCI::RakeTaskHelpers
    
    attr_accessor :destroy_timeout_in_seconds
    
    # @param [String] name The task name.
    # @param [String] desc Description of the task.
    def initialize(name = 'vagrant_destroy', desc = 'Vagrant destroy task')
      @name, @desc = name, desc
      @destroy_timeout_in_seconds = 180
      yield self if block_given?
      define_task
    end
    
    private

    def define_task
      desc @desc
      task @name do
        vagrant = DaptivChefCI::VagrantDriver.new()
        execute { vagrant.destroy({ :cmd_timeout_in_seconds => @destroy_timeout_in_seconds }) }
      end
    end

  end
end

