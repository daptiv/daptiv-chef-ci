require 'log4r'
require 'mixlib/shellout/exceptions'
require_relative 'shell'

module DaptivChefCI
  # Drives Vagrant via the command shell
  class VagrantDriver
    # Constructs a new Vagrant management instance
    #
    # @param [String] The name of the Vagrant virtualization provider:
    # => virtualbox (default), vmware_fusion
    # @param [Shell] The CLI, optional
    def initialize(provider = :virtualbox, shell = nil)
      @logger = Log4r::Logger.new('daptiv_chef_ci::vagrant')
      @shell = shell || DaptivChefCI::Shell.new
      @provider = provider
    end

    def destroy(opts = {})
      opts = {
        cmd_timeout_in_seconds: 180,
        retry_attempts: 2,
        retry_wait_in_seconds: 20,
        continue_on_error: true
      }.merge(opts)
      exec_cmd_with_retry('vagrant destroy -f', opts)
    end

    def halt(opts = {})
      opts = {
        cmd_timeout_in_seconds: 180,
        retry_attempts: 2,
        retry_wait_in_seconds: 20
      }.merge(opts)
      exec_cmd_with_retry('vagrant halt', opts)
    end

    def up(opts = {})
      opts = {
        cmd_timeout_in_seconds: 7200,
        retry_attempts: 0
      }.merge(opts)
      cmd = 'vagrant up'
      cmd += ' --provider=' + @provider.to_s
      exec_cmd_with_retry(cmd, opts)
    end

    def provision(opts = {})
      opts = {
        cmd_timeout_in_seconds: 7200,
        retry_attempts: 0
      }.merge(opts)
      exec_cmd_with_retry('vagrant provision', opts)
    end

    private

    def exec_cmd_with_retry(cmd, options)
      attempt ||= 1
      opts ||= ensure_defaults(options)
      @shell.exec_cmd(cmd, opts[:cmd_timeout_in_seconds], opts[:environment])
    rescue Mixlib::ShellOut::ShellCommandFailed => e
      @logger.warn("#{cmd} failed with error: #{e.message}")
      if attempt > opts[:retry_attempts]
        return if opts[:continue_on_error]
        raise
      end
      attempt += 1
      sleep(opts[:retry_wait_in_seconds])
      retry
    end

    def ensure_defaults(opts)
      {
        environment: {},
        cmd_timeout_in_seconds: 600,
        retry_attempts: 0,
        retry_wait_in_seconds: 10,
        continue_on_error: false
      }.merge(opts)
    end
  end
end
