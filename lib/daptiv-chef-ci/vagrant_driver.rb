require 'log4r'
require 'mixlib/shellout/exceptions'
require_relative 'basebox_builder_factory'
require_relative 'shell'

module DaptivChefCI
  class VagrantDriver
    
    # Constructs a new Vagrant management instance
    #
    # @param [String] The name of the Vagrant virtualization provider: virtualbox, vmware_fusion
    # defaults to :virtualbox
    # @param [Shell] The CLI, optional
    # @param [BaseBoxBuilderFactory] The base box builder factory instance, optional
    def initialize(provider = :virtualbox, shell = nil, basebox_builder_factory = nil)
      @logger = Log4r::Logger.new("daptiv_chef_ci::vagrant")
      @shell = shell || DaptivChefCI::Shell.new()
      @basebox_builder_factory = basebox_builder_factory || DaptivChefCI::BaseBoxBuilderFactory.new()
      @provider = provider
    end
    
    def destroy(opts={})
      opts = {
        :cmd_timeout_in_seconds => 180,
        :retry_attempts => 2,
        :retry_wait_in_seconds => 20
      }.merge(opts)
      exec_cmd_with_retry('vagrant destroy -f', opts)
    end
    
    def halt(opts={})
      opts = {
        :cmd_timeout_in_seconds => 180,
        :retry_attempts => 2,
        :retry_wait_in_seconds => 20
      }.merge(opts)
      exec_cmd_with_retry('vagrant halt', opts)
    end
    
    def up(opts={})
      opts = {
        :cmd_timeout_in_seconds => 7200,
        :retry_attempts => 0
      }.merge(opts)
      cmd = 'vagrant up'
      cmd += ' --provider=' + @provider.to_s if @provider != :virtualbox
      exec_cmd_with_retry(cmd, opts)
    end
    
    def provision(opts={})
      opts = {
        :cmd_timeout_in_seconds => 7200,
        :retry_attempts => 0
      }.merge(opts)
      exec_cmd_with_retry('vagrant provision', opts)
    end
    
    def reload(opts={})
      opts = {
        :cmd_timeout_in_seconds => 180,
        :retry_attempts => 0
      }.merge(opts)
      exec_cmd_with_retry('vagrant reload', opts)
    end
    
    def package(opts={})
      base_dir = opts[:base_dir] || Dir.pwd
      box_name = opts[:box_name] || File.basename(base_dir)
      box_name += '.box' unless box_name.end_with?('.box')
      
      builder = @basebox_builder_factory.create(@shell, @provider, base_dir)
      builder.build(box_name)
    end
    
    
    private
    
    def exec_cmd_with_retry(cmd, opts)
      attempt ||= 1
      @shell.exec_cmd(cmd, opts[:cmd_timeout_in_seconds] || 600)
    rescue Mixlib::ShellOut::ShellCommandFailed => e
      @logger.warn("#{cmd} failed with error: #{e.message}")
      raise if attempt > (opts[:retry_attempts] || 0)
      attempt += 1
      sleep(opts[:retry_wait_in_seconds] || 10)
      retry
    end
    
  end
end