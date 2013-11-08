require 'rake'
require 'rake/tasklib'
require_relative 'vagrant_driver'
require_relative 'logger'

begin
  # Support Rake > 0.8.7
  require 'rake/dsl_definition'
rescue LoadError
end

DaptivChefCI::Logger.init()

class VagrantUp
  
  # Example usage, ups and provisions a Vagrant box without halting or destroying it.
  #
  # VagrantUp::RakeTask.new 'up' do |t|
  #   t.provider = :vmware_fusion
  #   t.box_name = 'windows-server-vmwarefusion.box'
  #   t.up_timeout_in_seconds = 3600
  # end
  #
  # This class lets you define Rake tasks to drive Vagrant.
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined? ::Rake::DSL
    
    attr_accessor :provider
    attr_accessor :up_timeout_in_seconds
    
    # @param [String] name The task name.
    # @param [String] desc Description of the task.
    # @param [String] provider vagrant provider to use if other than the default virtualbox provider
    def initialize(name = 'vagrant', desc = 'Vagrant up task')
      @name, @desc = name, desc
      @provider = :virtualbox
      @up_timeout_in_seconds = 7200
      yield self if block_given?
      define_task
    end
    
    private

    def define_task
      desc @desc
      task @name do
        vagrant = DaptivChefCI::VagrantDriver.new(@provider)
        try_vagrant_up(vagrant)
      end
    end
    
    def try_vagrant_up(vagrant)
      begin
        vagrant.up({ :cmd_timeout_in_seconds => @provision_timeout_in_seconds })
      rescue SystemExit => ex
        exit(ex.status)
      rescue Exception => ex
        STDERR.puts("#{ex.message} (#{ex.class})")
        STDERR.puts(ex.backtrace.join("\n"))
        exit(1)
      end
    end

  end
end

