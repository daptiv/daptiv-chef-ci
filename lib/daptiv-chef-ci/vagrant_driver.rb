require 'log4r'
require 'mixlib/shellout/exceptions'
require_relative 'shell'

module DaptivChefCI
  class VagrantDriver
    
    # Constructs a new Vagrant management instance
    #
    # @param [Shell] The CLI
    def initialize(shell)
      @logger = Log4r::Logger.new("daptiv_chef_ci::vagrant")
      @shell = shell
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
        :retry_attempts => 0,
        :provider => ''
      }.merge(opts)
      provider = opts[:provider]
      cmd = provider.empty? ? 'vagrant up' : 'vagrant up --provider=' + provider
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