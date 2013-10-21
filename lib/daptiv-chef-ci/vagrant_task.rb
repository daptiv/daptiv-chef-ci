require 'rake'
require 'rake/tasklib'
require_relative 'vagrant_driver'
require_relative 'virtualbox_driver'
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
  #
  # @example Run the Python and NGinx cookbooks on a Linux guest
  #   Vagrant::RakeTask.new do |task|
  #     task.box_name = 'vagrant-FreeBSD'
  #     task.run_list = [ 'python', 'nginx' ]
  #     task.chef_repo_dir = '/Users/me/chef-repo'
  #   end
  #
  # @example Run the Python and NGinx cookbooks on a Windows guest
  #   Vagrant::RakeTask.new do |task|
  #     task.guest_os = :windows
  #     task.box_name = 'vagrant-windows-server-r2'
  #     task.box_url = 'http://example.com/boxes/vagrant-windows-server-r2.box'
  #     task.run_list = [ 'python', 'nginx' ]
  #     task.chef_repo_dir = '/Users/me/chef-repo'
  #   end
  #
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined? ::Rake::DSL
    
    attr_accessor :guest_os
    attr_accessor :box_url
    attr_accessor :box_name
    attr_accessor :run_list
    attr_accessor :node_name
    attr_accessor :chef_repo_dir
    attr_accessor :chef_json
    
    # @param [String] name The task name.
    # @param [String] desc Description of the task.
    def initialize(name = 'vagrant', desc = 'Daptiv Vagrant Tasks')
      @name, @desc = name, desc
      @guest_os = nil
      @box_url = nil
      @box_name = nil
      @run_list = []
      @node_name = nil
      @chef_repo_dir = nil
      @chef_json = nil

      yield self if block_given?

      define_task
    end
    

    private

    def define_task
      desc @desc
      task @name do
        
        options = {
          :guest_os => @guest_os,
          :box_url => @box_url,
          :box_name => @box_name,
          :run_list => @run_list,
          :node_name => @node_name,
          :chef_repo_dir => @chef_repo_dir,
          :chef_json => @chef_json }
        
        shell = DaptivChefCI::Shell.new()
        vagrant = DaptivChefCI::VagrantDriver.new(shell, options)

        vagrant.create_vagrantfile()
        
        begin
          vagrant.destroy()
        rescue SystemExit => ex
          exit(ex.status)
        rescue Exception => ex
          print_err(ex)
        end
        
        begin
          vagrant.up()
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
    end
    
    def print_err(ex)
      STDERR.puts("#{ex.message} (#{ex.class})")
      STDERR.puts(ex.backtrace.join("\n"))
    end
    
  end
end

