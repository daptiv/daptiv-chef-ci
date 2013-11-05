require 'rake'
require 'rake/tasklib'
require_relative 'vagrant_driver'
require_relative 'virtualbox_driver'
require_relative 'basebox_builder_factory'
require_relative 'shell'
require_relative 'logger'

begin
  # Support Rake > 0.8.7
  require 'rake/dsl_definition'
rescue LoadError
end

DaptivChefCI::Logger.init()

class Vagrant
  
  # This class lets you define Rake tasks to drive Vagrant.
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined? ::Rake::DSL
    
    attr_accessor :provider
    attr_accessor :create_box
    attr_accessor :vagrantfile_dir
    attr_accessor :box_name
    
    # @param [String] name The task name.
    # @param [String] desc Description of the task.
    # @param [String] provider vagrant provider to use if other than the default virtualbox provider
    def initialize(name = 'vagrant', desc = 'Daptiv Vagrant Tasks')
      @name, @desc = name, desc
      @provider = :virtualbox
      @create_box = false
      @vagrantfile_dir = Dir.pwd
      @box_name = nil
      yield self if block_given?
      define_task
    end
    
    private

    def define_task
      desc @desc
      task @name do
        shell = DaptivChefCI::Shell.new()
        basebox_builder_factory = DaptivChefCI::BaseBoxBuilderFactory.new()
        vagrant = DaptivChefCI::VagrantDriver.new(shell, basebox_builder_factory, @provider)
        execute_vagrant_run(vagrant)
      end
    end
    
    def execute_vagrant_run(vagrant)
      try_destroy_before_vagrant_up(vagrant)
      try_vagrant_up(vagrant)
    end
    
    def try_destroy_before_vagrant_up(vagrant)
      begin
        vagrant.destroy()
      rescue SystemExit => ex
        exit(ex.status)
      rescue Exception => ex
        print_err(ex)
      end
    end
    
    def try_vagrant_up(vagrant)
      begin
        vagrant.up()
        vagrant.halt()
        vagrant.package({ :base_dir => @vagrantfile_dir, :box_name => @box_name }) if @create_box
      rescue SystemExit => ex
        exit(ex.status)
      rescue Exception => ex
        print_err(ex)
        exit(1) 
      ensure
        vagrant.halt()
        vagrant.destroy()
      end
    end
    
    def print_err(ex)
      STDERR.puts("#{ex.message} (#{ex.class})")
      STDERR.puts(ex.backtrace.join("\n"))
    end
    
  end
end

