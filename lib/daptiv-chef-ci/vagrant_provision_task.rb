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

class VagrantProvision
  
  # Example usage, provisions a vmware box (box must already be up):
  #
  # VagrantProvision::RakeTask.new 'provision' do |t|
  #   t.provider = :vmware_fusion
  #   t.box_name = 'windows-server-vmwarefusion.box'
  #   t.provision_timeout_in_seconds = 3600
  #   t.provsion_retry_attempts = 2
  # end
  #
  # This class lets you define Rake tasks to drive Vagrant.
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined? ::Rake::DSL
    
    attr_accessor :provider
    attr_accessor :provision_timeout_in_seconds
    attr_accessor :provsion_retry_attempts
    
    # @param [String] name The task name.
    # @param [String] desc Description of the task.
    # @param [String] provider vagrant provider to use if other than the default virtualbox provider
    def initialize(name = 'vagrant', desc = 'Vagrant provision task')
      @name, @desc = name, desc
      @provider = :virtualbox
      @provision_timeout_in_seconds = 7200
      @provsion_retry_attempts = 0
      yield self if block_given?
      define_task
    end
    
    private

    def define_task
      desc @desc
      task @name do
        vagrant = DaptivChefCI::VagrantDriver.new(@provider)
        try_vagrant_provision(vagrant)
      end
    end
    
    def try_vagrant_provision(vagrant)
      begin
        vagrant.provision({ :cmd_timeout_in_seconds => @provision_timeout_in_seconds, :retry_attempts => @provsion_retry_attempts })
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

